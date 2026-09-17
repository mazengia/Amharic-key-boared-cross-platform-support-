import 'dart:io';

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
}