/// Immutable value object holding the user's keyboard preferences.
///
/// Kept separate from [SettingsScreen]'s widget state so it can be
/// loaded/saved by [SettingsService] and reused anywhere else in the
/// app (e.g. by the engine bridge) without touching UI code.
class AppSettings {
  final bool enabled;
  final bool suggestions;
  final bool autoCommit;
  final String layout;

  const AppSettings({
    required this.enabled,
    required this.suggestions,
    required this.autoCommit,
    required this.layout,
  });

  static const defaults = AppSettings(
    enabled: true,
    suggestions: true,
    autoCommit: true,
    layout: 'Phonetic',
  );

  AppSettings copyWith({
    bool? enabled,
    bool? suggestions,
    bool? autoCommit,
    String? layout,
  }) {
    return AppSettings(
      enabled: enabled ?? this.enabled,
      suggestions: suggestions ?? this.suggestions,
      autoCommit: autoCommit ?? this.autoCommit,
      layout: layout ?? this.layout,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'suggestions': suggestions,
      'autoCommit': autoCommit,
      'layout': layout,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      enabled: json['enabled'] as bool? ?? defaults.enabled,
      suggestions: json['suggestions'] as bool? ?? defaults.suggestions,
      autoCommit: json['autoCommit'] as bool? ?? defaults.autoCommit,
      layout: json['layout'] as String? ?? defaults.layout,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppSettings &&
        other.enabled == enabled &&
        other.suggestions == suggestions &&
        other.autoCommit == autoCommit &&
        other.layout == layout;
  }

  @override
  int get hashCode => Object.hash(enabled, suggestions, autoCommit, layout);
}