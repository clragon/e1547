import 'dart:convert';

import 'package:e1547/settings/data/preferences/nullable_preferences.dart';
import 'package:e1547/settings/data/preferences/retype.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads value from [key].
typedef PreferenceReader<T> = T? Function(String key);

/// Writes [value] to [key].
typedef PreferenceWriter<T> = Future<bool> Function(String key, T value);

/// Reads a Preference from [SharedPreferences].
typedef ReadPreference<T> = T? Function(SharedPreferences prefs, String key);

/// Writes a Preference to [SharedPreferences].
typedef WritePreference<T> = void Function(
    SharedPreferences prefs, String key, T value);

/// Used to instantiate a JSON object from a Preference string.
typedef DecodeJsonPreference<T> = T Function(dynamic json);

/// Provides utility functions for interacting with [SharedPreferences].
/// Cannot be instantiated. Please use the static methods which are provided.
abstract class PreferenceAdapter {
  /// Finds a matching reader for a Preference in [SharedPreferences].
  /// Known types are `String, int, double, bool, List<String>` and their nullable versions.
  static PreferenceReader<T>? getReader<T>(SharedPreferences prefs) {
    if (_isTypeOrNull<String, T>()) {
      return prefs.getString as PreferenceReader<T>;
    }
    if (_isTypeOrNull<int, T>()) {
      return prefs.getInt as PreferenceReader<T>;
    }
    if (_isTypeOrNull<double, T>()) {
      return prefs.getDouble as PreferenceReader<T>;
    }
    if (_isTypeOrNull<bool, T>()) {
      return prefs.getBool as PreferenceReader<T>;
    }
    if (_isTypeOrNull<List<String>, T>()) {
      return prefs.getStringList as PreferenceReader<T>;
    }
    throw PreferenceReadError<T>();
  }

  /// Reads a Preference from [SharedPreferences].
  static T readSetting<T>({
    required SharedPreferences prefs,
    required String key,
    required T initialValue,
    ReadPreference<T>? read,
  }) {
    T? value;
    if (read != null) {
      value = read(prefs, key);
    } else {
      PreferenceReader<T>? deserialize = getReader<T>(prefs);
      value = deserialize?.call(key);
    }
    return value ?? initialValue;
  }

  /// Reads an object from [SharedPreferences] by decoding it with [JsonCodec.encode].
  ///
  /// A [fromJson] method be provided to instantiate the object.
  static ReadPreference<T> jsonReader<T>(DecodeJsonPreference<T> fromJson) =>
      (prefs, key) {
        String? value = prefs.getString(key);
        T? result;
        if (value != null) {
          result = fromJson(json.decode(value));
        }
        return result;
      };

  /// Reads an Enum from [SharedPreferences].
  ///
  /// The [values] parameter is a list of all possible Enum values.
  static ReadPreference<T> enumReader<T extends Enum>(List<T> values) =>
      (prefs, key) => values.asNameMap()[prefs.getString(key)];

  /// Finds a matching writer for a Preference in [SharedPreferences].
  /// Known types are `String, int, double, bool, List<String>` and their nullable versions.
  static PreferenceWriter<T>? getWriter<T>(SharedPreferences prefs) {
    if (_isTypeOrNull<String, T>()) {
      return prefs.setStringOrNull as PreferenceWriter<T>;
    }
    if (_isTypeOrNull<int, T>()) {
      return prefs.setIntOrNull as PreferenceWriter<T>;
    }
    if (_isTypeOrNull<double, T>()) {
      return prefs.setDoubleOrNull as PreferenceWriter<T>;
    }
    if (_isTypeOrNull<bool, T>()) {
      return prefs.setBoolOrNull as PreferenceWriter<T>;
    }
    if (_isTypeOrNull<List<String>, T>()) {
      return prefs.setStringListOrNull as PreferenceWriter<T>;
    }
    throw PreferenceWriteError<T>();
  }

  /// Writes a Preference to [SharedPreferences].
  static void writeSetting<T>({
    required SharedPreferences prefs,
    required String key,
    required T value,
    WritePreference<T>? write,
  }) async {
    if (write != null) {
      write(prefs, key, value);
    } else {
      PreferenceWriter<T>? serialize = getWriter<T>(prefs);
      await serialize?.call(key, value);
    }
  }

  /// Writes an object to [SharedPreferences] by encoding it with [JsonCodec.encode].
  ///
  /// Types that are used with this must provide a toJson method.
  static void jsonWriter<T>(SharedPreferences prefs, String key, T? value) {
    String? result;
    if (value != null) {
      result = json.encode(value);
    }
    prefs.setStringOrNull(key, result);
  }

  /// Writes an Enum to [SharedPreferences].
  ///
  /// The Enum is stored as a String.
  static void enumWriter<T extends Enum?>(
          SharedPreferences prefs, String key, T value) =>
      prefs.setStringOrNull(key, value?.name);

  /// Compares a generic [T] and [T]? to another generic [E].
  static bool _isTypeOrNull<T, E>() => ReType<E>().isSubTypeOf(ReType<T?>());
}

/// An error that is thrown when [PreferenceAdapter] cannot find a matching Reader for the given Preference Type.
/// Supported Preference types include: `String, int, double, bool, List<String>` and their nullable versions.
/// If you encounter this, please provide your own Reader with the [ReadPreference] parameter.
class PreferenceReadError<T> extends Error {
  @override
  String toString() =>
      "Error: PreferenceUtilities failed to read $T because it wasn't String, int, double, bool or List<String>."
      '\nPlease provide a reader callback.';
}

/// An error that is thrown when [PreferenceAdapter] cannot find a matching Writer for the given Preference Type.
/// Supported Preference types include: `String, int, double, bool, List<String>` and their nullable versions.
/// If you encounter this, please provide your own Writer with the [WritePreference] parameter.
class PreferenceWriteError<T> extends Error {
  @override
  String toString() =>
      "Error: PreferenceUtilities failed to write $T because it wasn't String, int, double, bool or List<String>."
      '\nPlease provide a writer callback.';
}
