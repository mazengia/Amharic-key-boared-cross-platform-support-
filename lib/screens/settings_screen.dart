import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../models/keyboard_layout.dart';
import '../services/ibus_service.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settingsService = SettingsService();
  final _ibusService = IBusService();

  AppSettings _settings = AppSettings.defaults;
  bool _loading = true;
  bool _applying = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final loaded = await _settingsService.load();

    if (!mounted) return;

    setState(() {
      _settings = loaded;
      _loading = false;
    });
  }

  Future<void> _updateSettings(AppSettings updated) async {
    setState(() {
      _settings = updated;
    });

    await _settingsService.save(updated);
  }

  Future<void> _apply() async {
    setState(() {
      _applying = true;
      _statusMessage = null;
    });

    // ibus-daemon isn't always autostarted the same way on Xorg vs.
    // Wayland sessions, so make sure it's up before touching engines.
    await _ibusService.ensureDaemonRunning();

    bool success;

    if (_settings.enabled) {
      success = await _ibusService.activate();
    } else {
      success = await _ibusService.restartIBus();
    }

    if (!mounted) return;

    setState(() {
      _applying = false;
      _statusMessage = success
          ? 'Settings applied.'
          : 'Could not reach IBus. Is ibus-daemon installed and running?';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

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
                  value: _settings.enabled,
                  onChanged: (value) {
                    _updateSettings(_settings.copyWith(enabled: value));
                  },
                ),

                const Divider(height: 1),

                ListTile(
                  title: const Text('Keyboard Layout'),
                  subtitle: const Text(
                    'Select your preferred input layout.',
                  ),
                  trailing: DropdownButton<String>(
                    value: _settings.layout,
                    items: [
                      for (final layout in KeyboardLayout.availableLayouts)
                        DropdownMenuItem(
                          value: layout,
                          child: Text(layout),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      _updateSettings(_settings.copyWith(layout: value));
                    },
                  ),
                ),

                const Divider(height: 1),

                SwitchListTile(
                  title: const Text('Word Suggestions'),
                  subtitle: const Text(
                    'Show candidate words while typing.',
                  ),
                  value: _settings.suggestions,
                  onChanged: (value) {
                    _updateSettings(_settings.copyWith(suggestions: value));
                  },
                ),

                const Divider(height: 1),

                SwitchListTile(
                  title: const Text('Automatic Commit'),
                  subtitle: const Text(
                    'Automatically commit completed words.',
                  ),
                  value: _settings.autoCommit,
                  onChanged: (value) {
                    _updateSettings(_settings.copyWith(autoCommit: value));
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
                          'across Ubuntu applications, on both Xorg and '
                          'Wayland sessions.',
                    ),
                  ),

                  FilledButton(
                    onPressed: _applying ? null : _apply,
                    child: _applying
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Apply'),
                  ),
                ],
              ),
            ),
          ),

          if (_statusMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _statusMessage!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}