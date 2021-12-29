import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef GetSetting<T> = T? Function(SharedPreferences prefs, String key);
typedef SetSetting<T> = void Function(
    SharedPreferences prefs, String key, T value);

typedef _SharedPrefsWriter<T> = Future<bool> Function(String key, T value);
typedef _SharedPrefsReader<T> = T? Function(String key);

/// An error that is thrown when SharedSettings cannot find a matching Reader for the given Settings Type.
/// Supported Settings types include: `String, int, double, bool, List<String>` and their nullable versions.
/// If you encounter this, please provide your own Reader with the GetSettings parameter.
class SharedSettingsReadError<T> extends Error {
  @override
  String toString() {
    return "Error: SharedSettings failed to read $T because it wasn't String, int, double, bool or List<String>.\nPlease provide a value for GetSetting.";
  }
}

/// An error that is thrown when SharedSettings cannot find a matching Writer for the given Settings Type.
/// Supported Settings types include: `String, int, double, bool, List<String>` and their nullable versions.
/// If you encounter this, please provide your own Writer with the SetSettings parameter.
class SharedSettingsWriteError<T> extends Error {
  @override
  String toString() {
    return "Error: SharedSettings failed to write $T because it wasn't String, int, double, bool or List<String>.\nPlease provide a value for SetSetting.";
  }
}

/// Adds convenience methods for saving values that might be null.
/// If the value is null, the corresponding key is removed.
extension Nullable on SharedPreferences {
  /// Saves a value to persistent storage in the background.
  /// If the value is null, the key is removed instead.
  Future<bool> _setValueOrNull<T>(
      String key, T? value, _SharedPrefsWriter<T> writer) {
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

/// Stores a Setting for [SharedSettings].
/// Is used to reset and reload settings.
class _SharedSetting<T> {
  final String key;
  final T initialValue;
  final GetSetting<T>? getSetting;
  final ValueNotifier<T> notifier;

  _SharedSetting({
    required this.notifier,
    required this.key,
    required this.initialValue,
    this.getSetting,
  });
}

/// Provides easily creating listenable Settings with [SharedPreferences].
///
/// This class is supposed to be extended.
/// A basic example of this is provided here:
///
/// ```dart
/// class Settings extends SharedSettings {
///   late final ValueNotifier<bool> hasSeenTutorial =
///   createSetting(key: 'hasSeenTutorial', initial: false);
///
///   late final ValueNotifier<bool> buttonClicks =
///   createSetting(key: 'buttonClicks', initial: 0);
/// }
/// ```
///
/// Since there is only ever one [SharedPreferences] and therefore [SharedSettings],
/// You should create a final global instance of your Settings object and inject it with imports, where it is needed.
///
/// ```dart
/// final Settings settings = Settings();
///
/// class Settings extends SharedSettings {
/// // ...
/// ```
///
/// The [SharedPreferences] have to be read from disk, so you have to initialize Settings in your main method:
/// ```dart
/// Future<void> main() async {
///   await settings.initialize();
///   runApp(MyApp());
/// }
/// ```
///
/// The settings object can then be used in combination with ValueListenableBuilder to provide and listen to your settings:
///
/// ```dart
/// ValueListenableBuilder<int>(
///   valueListenable: settings.buttonClicks,
///   builder: (context, value, child) => Text('You have clicked the button $value times!'),
/// )
/// ```
///
/// And it can be used to set the value and update all listening widgets:
/// ```dart
/// FloatingActionButton(
///   child: Icon(Icons.add),
///   onPressed: () {
///     settings.buttonClicks.value++;
///   },
/// )
/// ```
///
/// If your Settings type does not match any of the predefined types,
/// which are `String, int, double, bool, List<String>` and their nullable counterparts,
/// you can provide custom methods to read and write it, like shown in the following example:
///
/// ```dart
/// late final ValueNotifier<Credentials?> credentials = createSetting(
///   key: 'credentials',
///   initial: null,
///   getSetting: (prefs, key) {
///     String? value = prefs.getString(key);
///     if (value != null) {
///       return Credentials.fromJson(value);
///     } else {
///       return null;
///     }
///   },
///   setSetting: (prefs, key, value) async {
///     if (value == null) {
///       prefs.remove(key);
///     } else {
///       prefs.setString(key, value.toJson());
///     }
///   },
/// );
/// ```
abstract class SharedSettings {
  late final SharedPreferences _prefs;
  final List<_SharedSetting> _settings = [];

  /// Initializes the [SharedSettings].
  /// This method should be called in your main method, before runApp.
  ///
  /// You can pass a custom [SharedPreferences] instance, in case you are using another library that wraps it.
  Future<void> initialize({SharedPreferences? preferences}) async {
    _prefs = preferences ?? await SharedPreferences.getInstance();
  }

  Type _typeify<T>() => T;

  bool _typeMatch<T, E>() {
    return T == E || _typeify<T?>() == E;
  }

  _SharedPrefsReader<T>? _getWriter<T>(SharedPreferences prefs) {
    if (_typeMatch<String, T>()) {
      return prefs.getString as _SharedPrefsReader<T>;
    }
    if (_typeMatch<int, T>()) {
      return prefs.getInt as _SharedPrefsReader<T>;
    }
    if (_typeMatch<bool, T>()) {
      return prefs.getBool as _SharedPrefsReader<T>;
    }
    if (T == _typeify<List<String>>() || T == _typeify<List<String>?>()) {
      return prefs.getStringList as _SharedPrefsReader<T>;
    }
    throw SharedSettingsWriteError<T>();
  }

  _SharedPrefsWriter<T>? _getReader<T>(SharedPreferences prefs) {
    if (_typeMatch<String, T>()) {
      return prefs.setStringOrNull as _SharedPrefsWriter<T>;
    }
    if (_typeMatch<int, T>()) {
      return prefs.setIntOrNull as _SharedPrefsWriter<T>;
    }
    if (_typeMatch<bool, T>()) {
      return prefs.setBoolOrNull as _SharedPrefsWriter<T>;
    }
    if (T == _typeify<List<String>>() || T == _typeify<List<String>?>()) {
      return prefs.setStringListOrNull as _SharedPrefsWriter<T>;
    }
    throw SharedSettingsReadError<T>();
  }

  T _readSetting<T>(String key, T initialValue, GetSetting<T>? getSetting) {
    T? value;
    if (getSetting != null) {
      value = getSetting(_prefs, key);
    } else {
      _SharedPrefsReader<T>? deserialize = _getWriter<T>(_prefs);
      value = deserialize?.call(key);
    }
    return value ?? initialValue;
  }

  void _writeSetting<T>(String key, T value, SetSetting<T>? setSetting) async {
    if (setSetting != null) {
      setSetting(_prefs, key, value);
    } else {
      _SharedPrefsWriter<T>? serialize = _getReader<T>(_prefs);
      await serialize?.call(key, value);
    }
  }

  /// Creates a new Setting of type [T].
  /// A key and an initial value have to be provided.
  ///
  /// The following types have default values for [getSetting] and [setSetting] :
  /// `String, int, double, bool, List<String>` and their nullable versions.
  ///
  /// - If you do not provide [getSetting] and [setSetting] methods and your type is not supported, an error will be thrown.
  ///
  /// - If your type is nullable and initially null, provide null for [initialValue].
  ///
  /// - It is possible to not use the [SharedPreferences] object passed to [getSetting] and [setSetting] and instead write your own logic for storing a Setting.
  ValueNotifier<T> createSetting<T>({
    required String key,
    required T initialValue,
    GetSetting<T>? getSetting,
    SetSetting<T>? setSetting,
  }) {
    ValueNotifier<T> setting =
        ValueNotifier<T>(_readSetting(key, initialValue, getSetting));
    setting.addListener(() => _writeSetting(key, setting.value, setSetting));
    _settings.add(_SharedSetting<T>(
      key: key,
      initialValue: initialValue,
      getSetting: getSetting,
      notifier: setting,
    ));
    return setting;
  }

  /// Creates an Enum Setting.
  /// The enum value is stored and read as by its `name` property.
  ValueNotifier<T> createEnumSetting<T extends Enum>({
    required String key,
    required T initialValue,
    required List<T> values,
  }) {
    return createSetting(
      key: key,
      initialValue: initialValue,
      getSetting: (prefs, key) {
        String? value = prefs.getString(key);
        return values.asNameMap()[value];
      },
      setSetting: (prefs, key, value) => prefs.setStringOrNull(key, value.name),
    );
  }

  /// Completes with true once the settings for the app have been cleared.
  Future<bool> clear() async {
    bool result = await _prefs.clear();
    if (result) {
      for (_SharedSetting setting in _settings) {
        setting.notifier.value =
            _readSetting(setting.key, setting.initialValue, setting.getSetting);
      }
    }
    return result;
  }

  /// Fetches the latest values from the host platform.
  ///
  /// Use this method to observe modifications that were made in native code
  /// (without using the plugin) while the app is running.
  Future<void> reload() async {
    await _prefs.reload();
    for (_SharedSetting setting in _settings) {
      setting.notifier.value =
          _readSetting(setting.key, setting.initialValue, setting.getSetting);
    }
  }
}
