import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/data/backend_api.dart';

void main() {
  late HttpServer server;
  late List<HttpRequest> seen;
  int status = 200;

  setUp(() async {
    seen = [];
    status = 200;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((req) {
      seen.add(req);
      req.response
        ..statusCode = status
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'deleted': status == 200}))
        ..close();
    });
  });
  tearDown(() => server.close(force: true));

  HttpBackendApi api() => HttpBackendApi('http://${server.address.host}:${server.port}');

  test('deleteMe: DELETE /api/v1/me, Authorization: Bearer <token>', () async {
    await api().deleteMe('tok-123');
    expect(seen, hasLength(1));
    expect(seen.single.method, 'DELETE');
    expect(seen.single.uri.path, '/api/v1/me');
    expect(seen.single.headers.value('authorization'), 'Bearer tok-123');
  });

  test('server 401/500 bo\'lsa BackendException(status) tashlaydi (muvaffaqiyat soxtalashtirilmaydi)', () async {
    for (final code in [401, 500]) {
      status = code;
      await expectLater(api().deleteMe('t'), throwsA(isA<BackendException>().having((e) => e.status, 'status', code)));
    }
  });

  test('baza URL oxiridagi "/" ortiqcha chiziq hosil qilmaydi', () async {
    await HttpBackendApi('http://${server.address.host}:${server.port}/').deleteMe('t');
    expect(seen.single.uri.path, '/api/v1/me');
  });

  test('ulanib bo\'lmasa BackendException (status null)', () async {
    final dead = HttpBackendApi('http://127.0.0.1:1');
    await expectLater(dead.deleteMe('t'), throwsA(isA<BackendException>().having((e) => e.status, 'status', isNull)));
  });

  test('NoBackendApi sozlanmagan: isConfigured=false', () {
    expect(const NoBackendApi().isConfigured, isFalse);
  });

  adminApiTests();
}

class _Server {
  _Server(this.server);
  final HttpServer server;
  final List<({String method, String path, String? auth, String body})> seen = [];
  int status = 200;
  Object reply = {};
}

Future<_Server> _start(Object Function(String method, String path) reply) async {
  final s = _Server(await HttpServer.bind(InternetAddress.loopbackIPv4, 0));
  s.server.listen((req) async {
    final body = await utf8.decoder.bind(req).join();
    s.seen.add((method: req.method, path: req.uri.path, auth: req.headers.value('authorization'), body: body));
    req.response
      ..statusCode = s.status
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(reply(req.method, req.uri.path)))
      ..close();
  });
  return s;
}

void adminApiTests() {
  group('admin va o\'rnatish API', () {
    late _Server s;
    late HttpBackendApi api;
    setUp(() async {
      s = await _start((m, p) {
        if (p == '/api/v1/me') return {'uid': 'u', 'isAdmin': true, 'pro': true};
        if (p == '/api/v1/admin/stats') {
          return {
            'generatedAt': '2026-10-31T10:00:00.000Z',
            'installs': {'total': 11, 'byPlatform': {'android': 7, 'ios': 3, 'web': 1}, 'new7d': 4, 'active7d': 6, 'active30d': 9},
            'users': {'total': 5, 'new7d': 2},
            'pro': {'paid': 1, 'grantedByAdmin': 2},
          };
        }
        if (p == '/api/v1/admin/grants' && m == 'GET') {
          return {'grants': [{'email': 'a@b.co', 'ends_at': null, 'granted_at': '2026-10-31 10:00:00'}, {'email': 'c@d.co', 'ends_at': '2027-01-01 00:00:00', 'granted_at': '2026-10-31 11:00:00'}]};
        }
        return {'ok': true};
      });
      api = HttpBackendApi('http://${s.server.address.host}:${s.server.port}');
    });
    tearDown(() => s.server.close(force: true));

    test('me: GET /api/v1/me, isAdmin va pro o\'qiladi', () async {
      final me = await api.me('tok');
      expect(me.isAdmin, isTrue);
      expect(me.pro, isTrue);
      expect(s.seen.single.method, 'GET');
      expect(s.seen.single.auth, 'Bearer tok');
    });

    test('adminStats: sonlar to\'g\'ri o\'qiladi', () async {
      final st = await api.adminStats('tok');
      expect(st.installsTotal, 11);
      expect(st.android, 7);
      expect(st.ios, 3);
      expect(st.web, 1);
      expect(st.new7d, 4);
      expect(st.active7d, 6);
      expect(st.active30d, 9);
      expect(st.usersTotal, 5);
      expect(st.usersNew7d, 2);
      expect(st.proPaid, 1);
      expect(st.proGranted, 2);
      expect(s.seen.single.path, '/api/v1/admin/stats');
    });

    test('adminStats: yetishmayotgan maydonlar 0 bo\'ladi (buzuq javobda yiqilmaydi)', () async {
      s = await _start((m, p) => {'installs': {}});
      final st = await HttpBackendApi('http://${s.server.address.host}:${s.server.port}').adminStats('t');
      expect(st.installsTotal, 0);
      expect(st.usersTotal, 0);
    });

    test('listGrants: email va muddat (cheksiz = null)', () async {
      final g = await api.listGrants('tok');
      expect(g.map((e) => e.email), ['a@b.co', 'c@d.co']);
      expect(g[0].endsAt, isNull);
      expect(g[1].endsAt, '2027-01-01 00:00:00');
    });

    test('grantPro: POST {email, days}; days yo\'q bo\'lsa cheksiz', () async {
      await api.grantPro('tok', 'x@y.co', days: 30);
      await api.grantPro('tok', 'x@y.co');
      expect(s.seen[0].method, 'POST');
      expect(s.seen[0].path, '/api/v1/admin/grants');
      expect(jsonDecode(s.seen[0].body), {'email': 'x@y.co', 'days': 30});
      expect(jsonDecode(s.seen[1].body), {'email': 'x@y.co'});
    });

    test('revokePro: DELETE {email}', () async {
      await api.revokePro('tok', 'x@y.co');
      expect(s.seen.single.method, 'DELETE');
      expect(jsonDecode(s.seen.single.body), {'email': 'x@y.co'});
    });

    test('recordInstall: POST /api/v1/installs, TOKENSIZ', () async {
      await api.recordInstall(installId: 'abcdefabcdefabcdef', platform: 'android', appVersion: '1.0.0');
      expect(s.seen.single.path, '/api/v1/installs');
      expect(s.seen.single.auth, isNull);
      expect(jsonDecode(s.seen.single.body), {'installId': 'abcdefabcdefabcdef', 'platform': 'android', 'appVersion': '1.0.0'});
    });

    test('403 / 500: BackendException(status)', () async {
      s.status = 403;
      await expectLater(api.adminStats('t'), throwsA(isA<BackendException>().having((e) => e.status, 'status', 403)));
      s.status = 500;
      await expectLater(api.me('t'), throwsA(isA<BackendException>().having((e) => e.status, 'status', 500)));
    });

    test('NoBackendApi: me = null-holat (admin emas, Pro emas), qolganlari hech narsa qilmaydi', () async {
      const n = NoBackendApi();
      final me = await n.me('t');
      expect(me.isAdmin, isFalse);
      expect(me.pro, isFalse);
      await n.recordInstall(installId: 'x', platform: 'web', appVersion: '1');
    });
  });
}
