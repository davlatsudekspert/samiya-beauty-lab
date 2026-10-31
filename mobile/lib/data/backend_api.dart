import 'dart:async';
import 'dart:io';

/// Backend (Cloudflare Worker) mijozi. Hozircha faqat hisobni o'chirish; qolganlari keyingi bosqichlarda.
class BackendException implements Exception {
  const BackendException([this.status]);
  final int? status; // null: tarmoq xatosi
  @override
  String toString() => 'BackendException($status)';
}

abstract class BackendApi {
  /// Backend manzili berilganmi (`--dart-define=API_BASE_URL=...`).
  bool get isConfigured;

  /// DELETE /api/v1/me: foydalanuvchining serverdagi barcha ma'lumotlarini o'chiradi.
  Future<void> deleteMe(String idToken);
}

/// Backend hali yo'q (manzil berilmagan): server ma'lumotlari ham yo'q, shuning uchun hech narsa qilinmaydi.
class NoBackendApi implements BackendApi {
  const NoBackendApi();
  @override
  bool get isConfigured => false;
  @override
  Future<void> deleteMe(String idToken) async {}
}

class HttpBackendApi implements BackendApi {
  HttpBackendApi(String baseUrl, {this.timeout = const Duration(seconds: 20)})
      : _base = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
  final String _base;
  final Duration timeout;

  @override
  bool get isConfigured => true;

  @override
  Future<void> deleteMe(String idToken) async {
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final req = await client.deleteUrl(Uri.parse('$_base/api/v1/me')).timeout(timeout);
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $idToken');
      final res = await req.close().timeout(timeout);
      await res.drain<void>();
      if (res.statusCode != 200) throw BackendException(res.statusCode);
    } on BackendException {
      rethrow;
    } catch (_) {
      throw const BackendException();
    } finally {
      client.close(force: true);
    }
  }
}
