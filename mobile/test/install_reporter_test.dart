import 'package:flutter_test/flutter_test.dart';
import 'package:samiya_beauty_lab/data/backend_api.dart';
import 'package:samiya_beauty_lab/data/install_reporter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_backend.dart';

class _Throwing extends FakeBackendApi {
  @override
  Future<void> recordInstall({required String installId, required String platform, required String appVersion}) async =>
      throw const BackendException();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('birinchi ochilish: tasodifiy ID yaratiladi va yuboriladi', () async {
    final b = FakeBackendApi();
    await reportInstall(b, platform: 'android', appVersion: '1.0.0');
    expect(b.installs, hasLength(1));
    expect(b.installs.single.platform, 'android');
    expect(b.installs.single.appVersion, '1.0.0');
    expect(b.installs.single.installId, matches(RegExp(r'^[A-Za-z0-9-]{16,64}$')));
  });

  test('keyingi ochilishlarda ID o\'zgarmaydi (bitta o\'rnatish = bitta ID)', () async {
    final b = FakeBackendApi();
    await reportInstall(b, platform: 'ios', appVersion: '1.0.0');
    await reportInstall(b, platform: 'ios', appVersion: '1.0.1');
    expect(b.installs[0].installId, b.installs[1].installId);
  });

  test('turli o\'rnatishlar turli ID oladi', () async {
    final b = FakeBackendApi();
    await reportInstall(b, platform: 'ios', appVersion: '1');
    SharedPreferences.setMockInitialValues({});
    await reportInstall(b, platform: 'ios', appVersion: '1');
    expect(b.installs[0].installId, isNot(b.installs[1].installId));
  });

  test('backend sozlanmagan: hech narsa yuborilmaydi', () async {
    final b = FakeBackendApi(configured: false);
    await reportInstall(b, platform: 'web', appVersion: '1');
    expect(b.installs, isEmpty);
  });

  test('server xatosi ilovani yiqitmaydi', () async {
    await reportInstall(_Throwing(), platform: 'web', appVersion: '1');
  });
}
