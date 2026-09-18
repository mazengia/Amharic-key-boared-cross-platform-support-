/// Static data describing the keyboard layouts the app can preview.
///
/// Pulled out of `KeyboardScreen` so the same rows/examples can be
/// reused (e.g. by the settings layout dropdown) without duplicating
/// literals across files.
class KeyboardLayout {
  const KeyboardLayout._();

  /// Row-by-row (Latin key, Amharic character) pairs for the phonetic
  /// layout preview.
  static const List<List<(String, String)>> phonetic = [
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

  /// Latin → Amharic example words shown on the Home and Keyboard screens.
  static const List<(String, String)> examples = [
    ('selam', 'ሰላም'),
    ('abebe', 'አበበ'),
    ('bet', 'ቤት'),
    ('ethiopia', 'ኢትዮጵያ'),
  ];

  /// Layout names offered in Settings. Only "Phonetic" has real key data
  /// today; "Fidel" is reserved for a future direct Ethiopic layout.
  static const List<String> availableLayouts = ['Phonetic', 'Fidel'];
}