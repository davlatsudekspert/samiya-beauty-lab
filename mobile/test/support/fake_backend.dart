import 'package:samiya_beauty_lab/data/backend_api.dart';

class FakeBackendApi implements BackendApi {
  FakeBackendApi({this.configured = true, this.fail = false, List<String>? order}) : order = order ?? [];
  bool configured;
  bool fail;
  final List<String> deleteTokens = [];
  final List<String> order; // auth bilan chaqiruv tartibini tekshirish uchun umumiy jurnal
  @override
  bool get isConfigured => configured;
  @override
  Future<void> deleteMe(String idToken) async {
    order.add('backend');
    deleteTokens.add(idToken);
    if (fail) throw const BackendException(500);
  }
}
