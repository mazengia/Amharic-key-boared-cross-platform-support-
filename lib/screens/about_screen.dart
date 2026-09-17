import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.keyboard,
              size: 80,
            ),

            const SizedBox(height: 24),

            Text(
              'Amharic Keyboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text('Version 0.1.0'),

            const SizedBox(height: 24),

            const SizedBox(
              width: 600,
              child: Text(
                'A modern Amharic phonetic input method designed '
                    'for Ubuntu Linux. The application provides a '
                    'desktop interface while the IBus engine provides '
                    'system-wide text input.',
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Flutter Desktop + IBus + Ethiopic Transliteration',
            ),
          ],
        ),
      ),
    );
  }
}