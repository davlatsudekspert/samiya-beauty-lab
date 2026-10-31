import 'package:flutter/material.dart';
import '../../ui/safe_nav.dart';


import '../../app/app_state.dart';
import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';
import 'manual_input_page.dart';
import 'ocr_extract.dart';
import 'text_scanner.dart';

/// 16 Skaner. Kamera/galereyadan tarkib matnini qurilmada o'qiydi (rasm serverga yuborilmaydi);
/// natija foydalanuvchi tekshirishi uchun qo'lda kiritish sahifasiga to'ldirilgan holda ochiladi.
class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool _busy = false;
  String? _message;

  Future<void> _pickSource() async {
    if (_busy) return;
    final state = AppScope.of(context);
    final l = AppLocalizations.of(context);
    if (!state.scanner.isAvailable) {
      setState(() => _message = l.scanUnavailable);
      return;
    }
    final source = await showModalBottomSheet<ScanSource>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            key: const Key('scan-source-camera'),
            leading: const Icon(Icons.photo_camera_outlined, color: SamiyaColors.rose),
            title: Text(l.scanSourceCamera),
            onTap: () => Navigator.pop(ctx, ScanSource.camera),
          ),
          ListTile(
            key: const Key('scan-source-gallery'),
            leading: const Icon(Icons.photo_library_outlined, color: SamiyaColors.rose),
            title: Text(l.scanSourceGallery),
            onTap: () => Navigator.pop(ctx, ScanSource.gallery),
          ),
        ])),
      ),
    );
    if (source == null || !mounted) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final raw = await state.scanner.scan(source);
      if (!mounted) return;
      if (raw == null) return; // foydalanuvchi o'zi bekor qildi
      final text = extractInciText(raw);
      if (text.isEmpty) {
        setState(() => _message = l.scanNoText);
      } else {
        context.safePush('/scanner/manual', extra: ManualInputArgs(text, fromScan: true));
      }
    } on ScanException catch (e) {
      if (mounted) setState(() => _message = e.kind == ScanFailure.unavailable ? l.scanUnavailable : l.scanFailed);
    } catch (_) {
      if (mounted) setState(() => _message = l.scanFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return KeyedSubtree(
      key: const Key('scanner-page'),
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 24),
        child: Column(children: [
          const _Viewfinder(),
          const SizedBox(height: 24),
          Text(l.scannerHeroTitle, textAlign: TextAlign.center, style: t.headlineSmall),
          const SizedBox(height: 8),
          Text(l.scannerHeroBody, textAlign: TextAlign.center, style: t.bodyLarge),
          const SizedBox(height: 24),
          if (_busy) ...[
            Row(key: const Key('scan-busy'), mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: SamiyaColors.rose)),
              const SizedBox(width: 12),
              Flexible(child: Text(l.scanReading, style: t.bodyLarge)),
            ]),
            const SizedBox(height: 16),
          ],
          if (_message != null) ...[
            Semantics(
              liveRegion: true,
              child: Container(
                key: const Key('scan-message'),
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F1),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFF2B8BD)),
                ),
                child: Text(_message!, style: t.bodyMedium?.copyWith(color: const Color(0xFF7A1F1A))),
              ),
            ),
            const SizedBox(height: 16),
          ],
          GradientButton(
            key: const Key('scan-manual'),
            label: l.scanManual,
            trailing: Icons.arrow_forward_rounded,
            onPressed: _busy ? null : () => context.safePush('/scanner/manual'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const Key('scan-camera'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: const StadiumBorder(),
                side: const BorderSide(color: SamiyaColors.rose, width: 1.4),
                foregroundColor: SamiyaColors.rose,
              ),
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(l.scanCamera, textAlign: TextAlign.center, style: t.titleMedium?.copyWith(color: SamiyaColors.rose, fontWeight: FontWeight.w700)),
              onPressed: _busy ? null : _pickSource,
            ),
          ),
        ]),
      ),
    );
  }
}

class _Viewfinder extends StatelessWidget {
  const _Viewfinder();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        height: 210,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: SamiyaShadows.soft,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF3EAE6), Color(0xFFE2CBC5)],
          ),
        ),
        child: CustomPaint(
          painter: _CornersPainter(),
          child: const Center(child: Icon(Icons.document_scanner_outlined, size: 76, color: Colors.white)),
        ),
      ),
    );
  }
}

class _CornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    const m = 28.0, len = 34.0;
    final r = Rect.fromLTWH(m, m, size.width - 2 * m, size.height - 2 * m);
    for (final (corner, dx, dy) in [
      (r.topLeft, 1.0, 1.0),
      (r.topRight, -1.0, 1.0),
      (r.bottomLeft, 1.0, -1.0),
      (r.bottomRight, -1.0, -1.0),
    ]) {
      canvas.drawLine(corner, corner + Offset(dx * len, 0), p);
      canvas.drawLine(corner, corner + Offset(0, dy * len), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
