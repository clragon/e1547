import 'dart:math';

/// Marker interface for class implementations that contain fake data.
interface class Fake {
  static final Random _random = Random();

  static int get number => _random.nextInt(1000);

  static int get id => number + number * 1000;

  static String get url => 'https://localhost/${word * 3}';

  static String chars(int charNo, [String char = 'C']) => char * charNo;

  static String get word => text(1);

  static String text(int words) =>
      List.generate(words, (_) => chars(_random.nextInt(12) + 3)).join(' ');

  static DateTime get date => DateTime(
    DateTime.now().year - _random.nextInt(10),
    _random.nextInt(12) + 1,
    _random.nextInt(28) + 1,
    _random.nextInt(24),
    _random.nextInt(60),
    _random.nextInt(60),
  );

  static T? flip<T>(T value, [double chance = 0.5]) {
    if (_random.nextDouble() < chance) {
      return value;
    }
    return null;
  }

  static bool get boolean => _random.nextBool();
}
