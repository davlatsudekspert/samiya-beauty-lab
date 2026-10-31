import 'package:flutter/material.dart';
import '../../ui/safe_nav.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets.dart';

/// 16 Skaner. Kamera/OCR hali ulanmagan (halol "tez orada"); qo'lda kiritish ishlaydi.
class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

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
          GradientButton(
            key: const Key('scan-manual'),
            label: l.scanManual,
            trailing: Icons.arrow_forward_rounded,
            onPressed: () => context.safePush('/scanner/manual'),
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
              onPressed: () => ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(l.comingSoon), behavior: SnackBarBehavior.floating)),
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
            colors: [Color(0xFFFFE3EC), Color(0xFFF4A9C0)],
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
