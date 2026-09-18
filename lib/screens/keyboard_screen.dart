import 'package:flutter/material.dart';

import '../models/keyboard_layout.dart';
import '../widgets/keyboard_key.dart';

class KeyboardScreen extends StatelessWidget {
  const KeyboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phonetic Keyboard',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Preview of the phonetic Amharic keyboard layout.',
          ),

          const SizedBox(height: 40),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  for (final row in KeyboardLayout.phonetic) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final key in row)
                          KeyboardKey(
                            latin: key.$1,
                            amharic: key.$2,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Typing examples',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: 16),

                  for (final example in KeyboardLayout.examples)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('${example.$1} → ${example.$2}'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}