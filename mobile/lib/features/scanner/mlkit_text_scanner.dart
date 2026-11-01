import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import 'text_scanner.dart';

/// Qurilma ichida (internetsiz) Google ML Kit bilan lotin yozuvini o'qiydi. Rasm serverga yuborilmaydi.
class MlkitTextScanner implements TextScanner {
  MlkitTextScanner({ImagePicker? picker}) : _picker = picker ?? ImagePicker();
  final ImagePicker _picker;

  @override
  bool get isAvailable => true;

  @override
  Future<String?> scan(ScanSource source) async {
    final XFile? file;
    try {
      file = await _picker.pickImage(source: source == ScanSource.camera ? ImageSource.camera : ImageSource.gallery, maxWidth: 2400, imageQuality: 92);
    } catch (_) {
      throw const ScanException(ScanFailure.failed); // ruxsat berilmagan yoki kamera yo'q
    }
    if (file == null) return null;
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(InputImage.fromFilePath(file.path));
      return result.text;
    } catch (_) {
      throw const ScanException(ScanFailure.failed);
    } finally {
      await recognizer.close();
    }
  }
}
