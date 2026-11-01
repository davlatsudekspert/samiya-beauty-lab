import 'package:url_launcher/url_launcher.dart';

/// Huquqiy sahifalar (backend'da, 4 tilda): maxfiylik, shartlar, hisobni o'chirish.
const legalBase = 'https://samiya-api.davlatsudekspert.workers.dev';

Uri legalUri(String page, String lang) => Uri.parse('$legalBase/$page?lang=$lang');

/// Tashqi havolani ochish (sinovlarda almashtiriladi).
Future<bool> Function(Uri) openExternalUrl = (u) async {
  try {
    return await launchUrl(u, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
};
