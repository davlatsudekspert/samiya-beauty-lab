import 'package:flutter/material.dart';

import 'brand.dart';

/// Nafis bo'sh holat: oltin monogramma, serif sarlavha, taklif matni.
class ElegantEmpty extends StatelessWidget {
  const ElegantEmpty({super.key, required this.title, required this.body, this.child});
  final String title;
  final String body;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          const SamiyaMark(size: 46),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: t.headlineSmall?.copyWith(fontSize: 25)),
          const SizedBox(height: 8),
          Text(body, textAlign: TextAlign.center, style: t.bodyLarge?.copyWith(fontSize: 15)),
          if (child != null) ...[const SizedBox(height: 16), child!],
        ],
      ),
    );
  }
}
