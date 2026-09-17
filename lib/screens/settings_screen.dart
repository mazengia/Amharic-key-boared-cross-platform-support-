import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool enabled = true;
  bool suggestions = true;
  bool autoCommit = true;

  String selectedLayout = 'Phonetic';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Configure your Amharic keyboard.',
          ),

          const SizedBox(height: 32),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable Amharic Keyboard'),
                  subtitle: const Text(
                    'Enable the system-wide Amharic input method.',
                  ),
                  value: enabled,
                  onChanged: (value) {
                    setState(() {
                      enabled = value;
                    });
                  },
                ),

                const Divider(height: 1),

                ListTile(
                  title: const Text('Keyboard Layout'),
                  subtitle: const Text(
                    'Select your preferred input layout.',
                  ),
                  trailing: DropdownButton<String>(
                    value: selectedLayout,
                    items: const [
                      DropdownMenuItem(
                        value: 'Phonetic',
                        child: Text('Phonetic'),
                      ),
                      DropdownMenuItem(
                        value: 'Fidel',
                        child: Text('Fidel'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        selectedLayout = value;
                      });
                    },
                  ),
                ),

                const Divider(height: 1),

                SwitchListTile(
                  title: const Text('Word Suggestions'),
                  subtitle: const Text(
                    'Show candidate words while typing.',
                  ),
                  value: suggestions,
                  onChanged: (value) {
                    setState(() {
                      suggestions = value;
                    });
                  },
                ),

                const Divider(height: 1),

                SwitchListTile(
                  title: const Text('Automatic Commit'),
                  subtitle: const Text(
                    'Automatically commit completed words.',
                  ),
                  value: autoCommit,
                  onChanged: (value) {
                    setState(() {
                      autoCommit = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const Icon(Icons.info_outline),

                  const SizedBox(width: 16),

                  const Expanded(
                    child: Text(
                      'The keyboard engine runs through IBus and works '
                          'across Ubuntu applications.',
                    ),
                  ),

                  FilledButton(
                    onPressed: () {},
                    child: const Text('Apply'),
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