import 'package:samiya_beauty_lab/data/backend_api.dart';

class FakeBackendApi implements BackendApi {
  FakeBackendApi({this.configured = true, this.fail = false, List<String>? order, this.meInfo = MeInfo.none}) : order = order ?? [];
  bool configured;
  bool fail;
  MeInfo meInfo;
  bool meFails = false;
  final List<String> deleteTokens = [];
  final List<String> order; // auth bilan chaqiruv tartibini tekshirish uchun umumiy jurnal
  final List<({String installId, String platform, String appVersion})> installs = [];
  final List<String> meTokens = [];
  AdminStats stats = const AdminStats(
      installsTotal: 11, android: 7, ios: 3, web: 1, new7d: 4, active7d: 6, active30d: 9, usersTotal: 5, usersNew7d: 2, proPaid: 1, proGranted: 2);
  final List<ProGrant> grants = [];
  final List<String> actions = [];
  bool adminFails = false;

  @override
  bool get isConfigured => configured;
  @override
  Future<void> deleteMe(String idToken) async {
    order.add('backend');
    deleteTokens.add(idToken);
    if (fail) throw const BackendException(500);
  }

  @override
  Future<MeInfo> me(String idToken) async {
    meTokens.add(idToken);
    if (meFails) throw const BackendException(500);
    return meInfo;
  }

  @override
  Future<void> recordInstall({required String installId, required String platform, required String appVersion}) async {
    installs.add((installId: installId, platform: platform, appVersion: appVersion));
  }

  @override
  Future<AdminStats> adminStats(String idToken) async {
    if (adminFails) throw const BackendException(500);
    return stats;
  }

  @override
  Future<List<ProGrant>> listGrants(String idToken) async {
    if (adminFails) throw const BackendException(500);
    return List.of(grants);
  }

  @override
  Future<void> grantPro(String idToken, String email, {int? days}) async {
    if (adminFails) throw const BackendException(500);
    actions.add('grant:$email:${days ?? 'forever'}');
    grants.removeWhere((g) => g.email == email);
    grants.add(ProGrant(email: email, endsAt: days == null ? null : '2027-01-01 00:00:00'));
  }

  @override
  Future<void> revokePro(String idToken, String email) async {
    if (adminFails) throw const BackendException(500);
    actions.add('revoke:$email');
    grants.removeWhere((g) => g.email == email);
  }
}
