import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Backend (Cloudflare Worker) mijozi.
class BackendException implements Exception {
  const BackendException([this.status, this.code]);
  final int? status; // null: tarmoq xatosi
  final String? code; // server xato kodi (masalan quota_exceeded, ai_not_configured)
  @override
  String toString() => 'BackendException($status, $code)';
}

/// SAMIYA AI javobi. [remaining]: bugun qolgan so'rovlar.
class AiAnswer {
  const AiAnswer({required this.answer, required this.remaining, required this.limit});
  final String answer;
  final int remaining;
  final int limit;
}

/// Suhbat tarixidagi bitta xabar (role: user yoki model).
class AiTurn {
  const AiTurn(this.role, this.text);
  final String role;
  final String text;
  Map<String, String> toJson() => {'role': role, 'text': text};
}

/// GET /api/v1/me javobi. Admin va Pro holati FAQAT serverdan (klient o'zi belgilamaydi).
class MeInfo {
  const MeInfo({required this.isAdmin, required this.pro});
  final bool isAdmin;
  final bool pro;
  static const none = MeInfo(isAdmin: false, pro: false);
}

/// Admin panel statistikasi. Eslatma: bu do'kondagi yuklab olishlar emas, kamida bir marta ochilgan o'rnatishlar.
class AdminStats {
  const AdminStats({
    required this.installsTotal,
    required this.android,
    required this.ios,
    required this.web,
    required this.new7d,
    required this.active7d,
    required this.active30d,
    required this.usersTotal,
    required this.usersNew7d,
    required this.proPaid,
    required this.proGranted,
  });

  final int installsTotal, android, ios, web, new7d, active7d, active30d;
  final int usersTotal, usersNew7d;
  final int proPaid, proGranted;

  factory AdminStats.fromJson(Map<String, dynamic> j) {
    int n(Object? v) => v is num ? v.toInt() : 0;
    Map<String, dynamic> m(Object? v) => v is Map<String, dynamic> ? v : const {};
    final inst = m(j['installs']), by = m(inst['byPlatform']), users = m(j['users']), pro = m(j['pro']);
    return AdminStats(
      installsTotal: n(inst['total']),
      android: n(by['android']),
      ios: n(by['ios']),
      web: n(by['web']),
      new7d: n(inst['new7d']),
      active7d: n(inst['active7d']),
      active30d: n(inst['active30d']),
      usersTotal: n(users['total']),
      usersNew7d: n(users['new7d']),
      proPaid: n(pro['paid']),
      proGranted: n(pro['grantedByAdmin']),
    );
  }
}

/// Admin bergan Pro (email bo'yicha). [endsAt] null = cheksiz.
class ProGrant {
  const ProGrant({required this.email, this.endsAt});
  final String email;
  final String? endsAt;
}

abstract class BackendApi {
  /// Backend manzili berilganmi (`--dart-define=API_BASE_URL=...`).
  bool get isConfigured;

  /// DELETE /api/v1/me: foydalanuvchining serverdagi barcha ma'lumotlarini o'chiradi.
  Future<void> deleteMe(String idToken);

  /// GET /api/v1/me: admin va Pro holati.
  Future<MeInfo> me(String idToken);

  /// POST /api/v1/installs: anonim o'rnatish hisoblagichi (token kerak emas).
  Future<void> recordInstall({required String installId, required String platform, required String appVersion});

  Future<AdminStats> adminStats(String idToken);
  Future<List<ProGrant>> listGrants(String idToken);

  /// Emailga Pro berish; [days] yo'q bo'lsa cheksiz.
  Future<void> grantPro(String idToken, String email, {int? days});
  Future<void> revokePro(String idToken, String email);

  /// POST /api/v1/ai/ask: kalit faqat serverda; kunlik kvota serverda.
  Future<AiAnswer> askAi(
    String idToken, {
    required String requestId,
    required String question,
    required String lang,
    String context = '',
    List<AiTurn> history = const [],
  });
}

/// Backend hali yo'q (manzil berilmagan): server ma'lumotlari ham yo'q, shuning uchun hech narsa qilinmaydi.
class NoBackendApi implements BackendApi {
  const NoBackendApi();
  @override
  bool get isConfigured => false;
  @override
  Future<void> deleteMe(String idToken) async {}
  @override
  Future<MeInfo> me(String idToken) async => MeInfo.none;
  @override
  Future<void> recordInstall({required String installId, required String platform, required String appVersion}) async {}
  @override
  Future<AdminStats> adminStats(String idToken) async => throw const BackendException();
  @override
  Future<List<ProGrant>> listGrants(String idToken) async => const [];
  @override
  Future<void> grantPro(String idToken, String email, {int? days}) async => throw const BackendException();
  @override
  Future<void> revokePro(String idToken, String email) async => throw const BackendException();
  @override
  Future<AiAnswer> askAi(
    String idToken, {
    required String requestId,
    required String question,
    required String lang,
    String context = '',
    List<AiTurn> history = const [],
  }) => throw const BackendException(503, 'ai_not_configured');
}

class HttpBackendApi implements BackendApi {
  HttpBackendApi(String baseUrl, {this.timeout = const Duration(seconds: 20)})
    : _base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
  final String _base;
  final Duration timeout;

  @override
  bool get isConfigured => true;

  /// Bitta so'rov. Status 200 bo'lmasa [BackendException]; tarmoq xatosi ham [BackendException] (status null).
  Future<Map<String, dynamic>> _send(String method, String path, {String? token, Object? body}) async {
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final req = await client.openUrl(method, Uri.parse('$_base$path')).timeout(timeout);
      if (token != null) req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      if (body != null) {
        req.headers.contentType = ContentType.json;
        req.add(utf8.encode(jsonEncode(body)));
      }
      final res = await req.close().timeout(timeout);
      final text = await utf8.decoder.bind(res).join().timeout(timeout);
      if (res.statusCode != 200) {
        String? code;
        try {
          final e = jsonDecode(text);
          if (e is Map && e['error'] is String) code = e['error'] as String;
        } catch (_) {}
        throw BackendException(res.statusCode, code);
      }
      final v = text.isEmpty ? null : jsonDecode(text);
      return v is Map<String, dynamic> ? v : <String, dynamic>{};
    } on BackendException {
      rethrow;
    } catch (_) {
      throw const BackendException();
    } finally {
      client.close(force: true);
    }
  }

  @override
  Future<void> deleteMe(String idToken) async {
    await _send('DELETE', '/api/v1/me', token: idToken);
  }

  @override
  Future<MeInfo> me(String idToken) async {
    final j = await _send('GET', '/api/v1/me', token: idToken);
    return MeInfo(isAdmin: j['isAdmin'] == true, pro: j['pro'] == true);
  }

  @override
  Future<void> recordInstall({required String installId, required String platform, required String appVersion}) async {
    await _send('POST', '/api/v1/installs', body: {'installId': installId, 'platform': platform, 'appVersion': appVersion});
  }

  @override
  Future<AdminStats> adminStats(String idToken) async => AdminStats.fromJson(await _send('GET', '/api/v1/admin/stats', token: idToken));

  @override
  Future<List<ProGrant>> listGrants(String idToken) async {
    final j = await _send('GET', '/api/v1/admin/grants', token: idToken);
    final list = j['grants'];
    if (list is! List) return const [];
    return [
      for (final g in list)
        if (g is Map && g['email'] is String) ProGrant(email: g['email'] as String, endsAt: g['ends_at'] as String?),
    ];
  }

  @override
  Future<void> grantPro(String idToken, String email, {int? days}) async {
    await _send('POST', '/api/v1/admin/grants', token: idToken, body: {'email': email, 'days': ?days});
  }

  @override
  Future<void> revokePro(String idToken, String email) async {
    await _send('DELETE', '/api/v1/admin/grants', token: idToken, body: {'email': email});
  }

  @override
  Future<AiAnswer> askAi(
    String idToken, {
    required String requestId,
    required String question,
    required String lang,
    String context = '',
    List<AiTurn> history = const [],
  }) async {
    final j = await _send(
      'POST',
      '/api/v1/ai/ask',
      token: idToken,
      body: {
        'requestId': requestId,
        'question': question,
        'lang': lang,
        'context': context,
        'history': [for (final h in history) h.toJson()],
      },
    );
    return AiAnswer(answer: (j['answer'] as String?) ?? '', remaining: (j['remaining'] as num?)?.toInt() ?? 0, limit: (j['limit'] as num?)?.toInt() ?? 0);
  }
}
