import 'dart:convert';
import 'dart:io';

import '../models/app_settings.dart';

/// Reads and writes [AppSettings] to a small JSON file under the user's
/// config directory. Uses dart:io directly (no shared_preferences
/// dependency) so it works the same under Xorg and Wayland sessions -
/// it never touches anything display-server specific.
class SettingsService {
  static const _fileName = 'settings.json';

  Directory _configDir() {
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '.';
    return Directory('$home/.config/amharic-keyboard');
  }

  File _settingsFile() => File('${_configDir().path}/$_fileName');

  Future<AppSettings> load() async {
    try {
      final file = _settingsFile();

      if (!await file.exists()) {
        return AppSettings.defaults;
      }

      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      return AppSettings.fromJson(data);
    } catch (_) {
      // Corrupt or unreadable file: fall back to defaults rather than
      // crashing the settings screen.
      return AppSettings.defaults;
    }
  }

  Future<bool> save(AppSettings settings) async {
    try {
      final dir = _configDir();

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final file = _settingsFile();
      await file.writeAsString(jsonEncode(settings.toJson()));

      return true;
    } catch (_) {
      return false;
    }
  }
}