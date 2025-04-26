import 'package:e1547/settings/data/preferences/preference_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Adds convenience methods for saving values to [SharedPreferences] that might be null.
/// If the value is null, the corresponding key is removed.
extension NullablePreferences on SharedPreferences {
  /// Saves a value to persistent storage in the background.
  /// If the value is null, the key is removed instead.
  Future<bool> _setValueOrNull<T>(
      String key, T? value, PreferenceWriter<T> writer) {
    if (value == null) {
      return remove(key);
    } else {
      return writer(key, value);
    }
  }

  /// Saves a boolean? [value] to persistent storage in the background.
  Future<bool> setBoolOrNull(String key, bool? value) =>
      _setValueOrNull(key, value, setBool);

  /// Saves an integer? [value] to persistent storage in the background.
  Future<bool> setIntOrNull(String key, int? value) =>
      _setValueOrNull(key, value, setInt);

  /// Saves a double? [value] to persistent storage in the background.
  ///
  /// Android doesn't support storing doubles, so it will be stored as a float.
  Future<bool> setDoubleOrNull(String key, double? value) =>
      _setValueOrNull(key, value, setDouble);

  /// Saves a string? [value] to persistent storage in the background.
  ///
  /// Note: Due to limitations in Android's SharedPreferences,
  /// values cannot start with any one of the following:
  ///
  /// - 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu'
  /// - 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBCaWdJbnRlZ2Vy'
  /// - 'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu'
  Future<bool> setStringOrNull(String key, String? value) =>
      _setValueOrNull(key, value, setString);

  /// Saves a list of strings? [value] to persistent storage in the background.
  Future<bool> setStringListOrNull(String key, List<String>? value) =>
      _setValueOrNull(key, value, setStringList);
}
