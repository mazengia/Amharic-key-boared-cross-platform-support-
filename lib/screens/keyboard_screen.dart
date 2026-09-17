import 'package:flutter/material.dart';

class KeyboardScreen extends StatelessWidget {
  const KeyboardScreen({super.key});

  static const rows = [
    [
      ('q', 'ቅ'),
      ('w', 'ው'),
      ('e', 'እ'),
      ('r', 'ር'),
      ('t', 'ት'),
      ('y', 'ይ'),
      ('u', 'ዑ'),
      ('i', 'ኢ'),
      ('o', 'ኦ'),
      ('p', 'ፕ'),
    ],
    [
      ('a', 'አ'),
      ('s', 'ስ'),
      ('d', 'ድ'),
      ('f', 'ፍ'),
      ('g', 'ግ'),
      ('h', 'ህ'),
      ('j', 'ጅ'),
      ('k', 'ክ'),
      ('l', 'ል'),
    ],
    [
      ('z', 'ዝ'),
      ('x', 'ጽ'),
      ('c', 'ች'),
      ('v', 'ቭ'),
      ('b', 'ብ'),
      ('n', 'ን'),
      ('m', 'ም'),
    ],
  ];

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
                  for (final row in rows) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final key in row)
                          _KeyboardKey(
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

                  const Text('selam → ሰላም'),
                  const SizedBox(height: 8),
                  const Text('abebe → አበበ'),
                  const SizedBox(height: 8),
                  const Text('bet → ቤት'),
                  const SizedBox(height: 8),
                  const Text('ethiopia → ኢትዮጵያ'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyboardKey extends StatelessWidget {
  final String latin;
  final String amharic;

  const _KeyboardKey({
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