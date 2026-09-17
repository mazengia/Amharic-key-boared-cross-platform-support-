import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amharic Keyboard',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'A modern phonetic Amharic input method for Ubuntu.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: _StatusCard(
                  icon: Icons.keyboard,
                  title: 'Keyboard',
                  value: 'Phonetic',
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: _StatusCard(
                  icon: Icons.language,
                  title: 'Language',
                  value: 'Amharic',
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: _StatusCard(
                  icon: Icons.check_circle,
                  title: 'Status',
                  value: 'Ready',
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Start',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _Instruction(
                    number: '1',
                    title: 'Enable the keyboard',
                    description:
                    'Enable Amharic Keyboard from the Settings page.',
                  ),

                  _Instruction(
                    number: '2',
                    title: 'Select Amharic',
                    description:
                    'Select the Amharic input method from Ubuntu.',
                  ),

                  _Instruction(
                    number: '3',
                    title: 'Start typing',
                    description:
                    'Type using English phonetic characters.',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Examples',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const _Example(
                    latin: 'selam',
                    amharic: 'ሰላም',
                  ),

                  const _Example(
                    latin: 'abebe',
                    amharic: 'አበበ',
                  ),

                  const _Example(
                    latin: 'bet',
                    amharic: 'ቤት',
                  ),

                  const _Example(
                    latin: 'ethiopia',
                    amharic: 'ኢትዮጵያ',
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

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatusCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, size: 32),

            const SizedBox(width: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Instruction extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _Instruction({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            child: Text(number),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Example extends StatelessWidget {
  final String latin;
  final String amharic;

  const _Example({
    required this.latin,
    required this.amharic,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              latin,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward),
          const SizedBox(width: 20),
          Text(
            amharic,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}