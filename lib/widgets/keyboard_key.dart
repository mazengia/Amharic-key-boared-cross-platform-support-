import 'package:flutter/material.dart';

/// A single key tile shown in the keyboard preview: the Latin letter
/// on top, the Amharic character it produces underneath.
class KeyboardKey extends StatelessWidget {
  final String latin;
  final String amharic;

  const KeyboardKey({
    super.key,
    required this.latin,
    required this.amharic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            latin.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amharic,
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}