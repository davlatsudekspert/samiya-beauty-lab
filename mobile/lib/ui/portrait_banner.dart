import 'package:flutter/material.dart';

import '../app/theme.dart';

/// Portretli pushti banner (kirish va bosh sahifada). Matn tomoni o'sadi, portret `end` tomonda.
class PortraitBanner extends StatelessWidget {
  const PortraitBanner({super.key, required this.title, this.eyebrow, this.tag, this.minHeight = 168, this.image = 'assets/images/ob2_routine.png'});
  final String image;
  final String title;
  final String? eyebrow;
  final String? tag;
  final double minHeight;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) => _build(context, c.maxWidth));

  Widget _build(BuildContext context, double width) {
    // Ingichka ekranda portret torayadi va matn kengroq maydon oladi (so'z o'rtasidan uzilmasligi uchun).
    final narrow = width < 330;
    final portraitW = narrow ? (width * 0.38).clamp(96.0, 180.0) : 180.0;
    final textEnd = portraitW - (narrow ? 14 : 30);
    final t = Theme.of(context).textTheme;
    final label = t.labelSmall?.copyWith(color: Colors.white, fontSize: 11, letterSpacing: 1.6);
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: SamiyaShadows.soft,
        gradient: const LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [Color(0xFF3B1E2B), Color(0xFF6B3D50)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            PositionedDirectional(
              top: 0,
              bottom: 0,
              end: 0,
              width: portraitW,
              child: ExcludeSemantics(
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (r) => const LinearGradient(
                    begin: AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd,
                    colors: [Colors.transparent, Colors.white],
                    stops: [0, 0.55],
                  ).createShader(r, textDirection: Directionality.of(context)),
                  child: Image.asset(image, fit: BoxFit.cover, alignment: Alignment.topCenter, filterQuality: FilterQuality.high),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(narrow ? 18 : 22, 22, textEnd, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (eyebrow != null) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, size: 13, color: Colors.white),
                        const SizedBox(width: 6),
                        Flexible(child: Text(eyebrow!, style: label)),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                  Text(
                    title,
                    style: t.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w500, fontSize: narrow ? 20 : null),
                  ),
                  if (tag != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      Localizations.localeOf(context).languageCode == 'ar' ? tag! : tag!.toUpperCase(),
                      style: label?.copyWith(color: Colors.white.withValues(alpha: 0.85), letterSpacing: 1.1),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
