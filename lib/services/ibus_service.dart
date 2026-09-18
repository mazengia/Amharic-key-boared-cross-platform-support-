import 'dart:io';

/// Thin wrapper around the `ibus` CLI. All calls go over D-Bus under
/// the hood, so this behaves identically on Xorg and Wayland sessions -
/// the one real difference between the two sessions is that
/// ibus-daemon isn't always autostarted on Wayland the way it is on
/// Xorg, which [ensureDaemonRunning] exists to paper over.
class IBusService {
  static const String engineName = 'amharic_phonetic';

  Future<bool> activate() async {
    try {
      final result = await Process.run(
        'ibus',
        ['engine', engineName],
      );

      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  Future<String> currentEngine() async {
    try {
      final result = await Process.run(
        'ibus',
        ['engine'],
      );

      return result.stdout.toString().trim();
    } catch (_) {
      return '';
    }
  }

  Future<bool> isActive() async {
    final engine = await currentEngine();
    return engine == engineName;
  }

  Future<bool> restartIBus() async {
    try {
      final result = await Process.run(
        'ibus',
        ['restart'],
      );

      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Checks whether ibus-daemon is running and starts it if not.
  ///
  /// Most Xorg desktop sessions launch ibus-daemon automatically as
  /// part of the input-method autostart chain. Several Wayland
  /// compositors don't do this consistently, so calling this before
  /// [activate] makes "Enable Amharic Keyboard" work the same on both.
  Future<bool> ensureDaemonRunning() async {
    try {
      final check = await Process.run('pgrep', ['-x', 'ibus-daemon']);

      if (check.exitCode == 0) {
        return true;
      }

      final start = await Process.run('ibus-daemon', ['-drx']);
      return start.exitCode == 0;
    } catch (_) {
      return false;
    }
  }
}