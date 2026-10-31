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
}
