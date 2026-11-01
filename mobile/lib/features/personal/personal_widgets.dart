import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../ui/honest_note.dart';

/// Kichik izoh qutisi (oltin chiziqli).
class SoftNote extends StatelessWidget {
  const SoftNote({super.key, required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => HonestNote(text);
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 23));
}

/// Matn kiritish + qo'shish tugmasi.
class AddRow extends StatelessWidget {
  const AddRow({
    super.key,
    required this.controller,
    required this.hint,
    required this.label,
    required this.onAdd,
    required this.inputKey,
    required this.buttonKey,
  });
  final TextEditingController controller;
  final String hint;
  final String label;
  final VoidCallback onAdd;
  final Key inputKey;
  final Key buttonKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            key: inputKey,
            controller: controller,
            maxLength: 120,
            decoration: InputDecoration(hintText: hint, counterText: ''),
            onSubmitted: (_) => onAdd(),
          ),
        ),
        const SizedBox(width: 10),
        FilledButton(
          key: buttonKey,
          style: FilledButton.styleFrom(
            backgroundColor: SamiyaColors.heading,
            minimumSize: const Size(56, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          onPressed: onAdd,
          child: Text(label),
        ),
      ],
    );
  }
}
