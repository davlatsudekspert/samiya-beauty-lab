enum ScanSource { camera, gallery }

enum ScanFailure { unavailable, failed }

class ScanException implements Exception {
  const ScanException(this.kind);
  final ScanFailure kind;
  @override
  String toString() => 'ScanException($kind)';
}

/// Rasmdan matn o'qish. Natija `null` bo'lsa foydalanuvchi o'zi bekor qilgan.
abstract class TextScanner {
  bool get isAvailable;
  Future<String?> scan(ScanSource source);
}

/// Kamera/OCR bo'lmagan muhit (veb, sinov): halol "mavjud emas".
class UnavailableTextScanner implements TextScanner {
  const UnavailableTextScanner();
  @override
  bool get isAvailable => false;
  @override
  Future<String?> scan(ScanSource source) async => throw const ScanException(ScanFailure.unavailable);
}
