import 'package:flutter/material.dart';

import '../app/theme.dart';

/// Portretli pushti banner (kirish va bosh sahifada). Matn tomoni o'sadi, portret `end` tomonda.
class PortraitBanner extends StatelessWidget {
  const PortraitBanner({super.key, required this.title, this.eyebrow, this.tag, this.minHeight = 168});
  final String title;
  final String? eyebrow;
  final String? tag;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
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
          colors: [Color(0xFFB85B7C), Color(0xFFD98BA2)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(children: [
          PositionedDirectional(
            top: 0,
            bottom: 0,
            end: 0,
            width: 180,
            child: ExcludeSemantics(
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (r) => const LinearGradient(
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                  colors: [Colors.transparent, Colors.white],
                  stops: [0, 0.55],
                ).createShader(r, textDirection: Directionality.of(context)),
                child: Image.asset('assets/images/ob2_routine.png',
                    fit: BoxFit.cover, alignment: Alignment.topCenter, filterQuality: FilterQuality.high),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(22, 22, 150, 22),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (eyebrow != null) ...[
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.auto_awesome_rounded, size: 13, color: Colors.white),
                  const SizedBox(width: 6),
                  Flexible(child: Text(eyebrow!, style: label)),
                ]),
                const SizedBox(height: 10),
              ],
              Text(title, style: t.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w500)),
              if (tag != null) ...[
                const SizedBox(height: 10),
                Text(Localizations.localeOf(context).languageCode == 'ar' ? tag! : tag!.toUpperCase(),
                    style: label?.copyWith(color: Colors.white.withValues(alpha: 0.85), letterSpacing: 1.1)),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}
