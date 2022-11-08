import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides easily creating listenable preferences with [SharedPreferences].
///
/// This class is supposed be used as a Mixin.
/// A basic example of this is provided here:
///
/// ```dart
/// class Settings with NotifiedPreferences {
///   late final PreferenceNotifier<bool> hasSeenTutorial =
///   createSetting(key: 'hasSeenTutorial', initial: false);
///
///   late final PreferenceNotifier<bool> buttonClicks =
///   createSetting(key: 'buttonClicks', initial: 0);
/// }
/// ```
///
/// There can only ever be one [SharedPreferences] and therefore [NotifiedPreferences].
/// It therefore makes sense to treat it as a quasi-global variable in your state management,
/// for example by using an [InheritedWidget] above [MaterialApp].
///
/// The [SharedPreferences] have to be read from disk, so you have to initialize Settings in your main method:
/// ```dart
/// Future<void> main() async {
///   await settings.initialize();
///   runApp(MyApp());
/// }
/// ```
///
/// The settings object can then be used in combination with [ValueListenableBuilder] to provide and listen to your settings:
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
/// late final PreferenceNotifier<Credentials?> credentials = createSetting(
///   key: 'credentials',
///   initial: null,
///   read: (prefs, key) {
///     String? value = prefs.getString(key);
///     if (value != null) {
///       return Credentials.fromJson(value);
///     } else {
///       return null;
///     }
///   },
///   write: (prefs, key, value) async =>
///     prefs.setStringOrNull(key: key, value: value?.toJson()),
/// );
/// ```
///
/// In this example we also use nullable extensions that the package provides
/// to write a String? to SharedPreferences.
/// This means, in case our String is null, we will instead delete the key.
abstract class NotifiedPreferences {
  /// Initializes the [NotifiedPreferences].
  /// This method should be called in your main method, before runApp.
  ///
  /// if you want to pass a custom [SharedPreferences] instance, use the constructor instead.
  Future<void> initialize() async =>
      _prefs = await SharedPreferences.getInstance();

  SharedPreferences? _prefs;
  final List<PreferenceNotifier> _notifiers = [];

  /// Creates a new Preference of type [T].
  /// A key and an initial value have to be provided.
  ///
  /// The following types have default values for [read] and [write] :
  /// `String, int, double, bool, List<String>` and their nullable versions.
  ///
  /// - If you do not provide [read] and [write] methods and your type is not supported, an error will be thrown.
  ///
  /// - If your type is nullable and initially null, provide null for [initialValue].
  ///
  /// - It is possible to not use the [SharedPreferences] object passed to [read] and [write] and instead write your own logic for storing a Preference.
  @protected
  PreferenceNotifier<T> createSetting<T>({
    required String key,
    required T initialValue,
    ReadPreference<T>? read,
    WritePreference<T>? write,
  }) {
    _assertInitialized();
    final notifier = PreferenceNotifier<T>(
      preferences: _prefs!,
      key: key,
      initialValue: initialValue,
      read: read,
      write: write,
    );
    _notifiers.add(notifier);
    return notifier;
  }

  /// Creates an Enum Setting.
  /// The enum value is stored and read as by its `name` property.
  @protected
  PreferenceNotifier<T> createEnumSetting<T extends Enum>({
    required String key,
    required T initialValue,
    required List<T> values,
  }) {
    _assertInitialized();
    return createSetting(
      key: key,
      initialValue: initialValue,
      read: (prefs, key) {
        String? value = prefs.getString(key);
        return values.asNameMap()[value];
      },
      write: (prefs, key, value) => prefs.setStringOrNull(key, value.name),
    );
  }

  /// Reloads the values of all Preferences.
  void _reload() {
    _assertInitialized();
    for (PreferenceNotifier setting in _notifiers) {
      setting._reload();
    }
  }

  /// Completes with true once the settings for the app have been cleared.
  Future<bool> clear() async {
    _assertInitialized();
    bool result = await _prefs!.clear();
    if (result) {
      _reload();
    }
    return result;
  }

  /// Fetches the latest values from the host platform.
  ///
  /// Use this method to observe modifications that were made in native code
  /// (without using the plugin) while the app is running.
  Future<void> reload() async {
    _assertInitialized();
    await _prefs!.reload();
    _reload();
  }

  /// Ensures that the [NotifiedPreferences] object has been properly initialized.
  void _assertInitialized() {
    if (_prefs == null) {
      throw StateError(
        '$runtimeType was not initialized!\n\n'
        'You must call the initalize() function on your NotifiedSharedPreferences extension before using it,'
        'to ensure that a SharedPreferences instance has been obtained!\n'
        'A good place to do so is in the main function:\n\n'
        'void main() {'
        '  $runtimeType settings = $runtimeType;'
        '  await settings.initialize();'
        '  runApp();'
        '}',
      );
    }
  }
}

/// Stores a Preference in [SharedPreferences].
/// When created, will read its own value from [SharedPreferences].
/// Notifies all its listeners whenever its value is changed.
/// Changes are written into the corresponding [SharedPreferences].
class PreferenceNotifier<T> extends ValueNotifier<T> {
  PreferenceNotifier({
    required SharedPreferences preferences,
    required this.key,
    required this.initialValue,
    this.read,
    this.write,
  })  : _prefs = preferences,
        super(
          PreferenceUtilities.readSetting<T>(
            prefs: preferences,
            key: key,
            initialValue: initialValue,
            read: read,
          ),
        );

  @override
  set value(T value) {
    if (this.value != value) {
      PreferenceUtilities.writeSetting<T>(
        prefs: _prefs,
        key: key,
        value: value,
        write: write,
      );
    }
    super.value = value;
  }

  /// Reads this setting from disk again.
  void _reload() {
    value = PreferenceUtilities.readSetting<T>(
      prefs: _prefs,
      key: key,
      initialValue: initialValue,
      read: read,
    );
  }

  /// The [SharedPreferences] in which this Preference is saved in.
  final SharedPreferences _prefs;

  /// The key for this Preference.
  final String key;

  /// The initial value of this Preference. Used when reading it would return null.
  final T initialValue;

  /// The method to read this Preference. This is required for special Types.
  final ReadPreference<T>? read;

  /// The method to write this Preference. This is required for special Types.
  final WritePreference<T>? write;

  /// Resets this Preference to its inital value.
  void reset() => value = initialValue;
}

/// Provides utility functions for interacting with [SharedPreferences].
/// Cannot be instantiated. Please use the static methods which are provided.
class PreferenceUtilities {
  PreferenceUtilities._();

  static Type _typeify<T>() => T;

  static bool _typeMatch<T, E>() => T == E || _typeify<T?>() == E;

  /// Finds a matching writer for a Preference in [SharedPreferences].
  /// Known types are `String, int, double, bool, List<String>` and their nullable versions.
  static PreferenceWriter<T>? getWriter<T>(SharedPreferences prefs) {
    if (_typeMatch<String, T>()) {
      return prefs.setStringOrNull as PreferenceWriter<T>;
    }
    if (_typeMatch<int, T>()) {
      return prefs.setIntOrNull as PreferenceWriter<T>;
    }
    if (_typeMatch<bool, T>()) {
      return prefs.setBoolOrNull as PreferenceWriter<T>;
    }
    if (T == _typeify<List<String>>() || T == _typeify<List<String>?>()) {
      return prefs.setStringListOrNull as PreferenceWriter<T>;
    }
    throw PreferenceReadError<T>();
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

  /// Finds a matching reader for a Preference in [SharedPreferences].
  /// Known types are `String, int, double, bool, List<String>` and their nullable versions.
  static PreferenceReader<T>? getReader<T>(SharedPreferences prefs) {
    if (_typeMatch<String, T>()) {
      return prefs.getString as PreferenceReader<T>;
    }
    if (_typeMatch<int, T>()) {
      return prefs.getInt as PreferenceReader<T>;
    }
    if (_typeMatch<bool, T>()) {
      return prefs.getBool as PreferenceReader<T>;
    }
    if (T == _typeify<List<String>>() || T == _typeify<List<String>?>()) {
      return prefs.getStringList as PreferenceReader<T>;
    }
    throw PreferenceWriteError<T>();
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
}

/// Used to read a Preference with [NotifiedPreferences].
typedef ReadPreference<T> = T? Function(SharedPreferences prefs, String key);

/// Used to write a Preference with [NotifiedPreferences].
typedef WritePreference<T> = void Function(
    SharedPreferences prefs, String key, T value);

typedef PreferenceWriter<T> = Future<bool> Function(String key, T value);
typedef PreferenceReader<T> = T? Function(String key);

/// An error that is thrown when [PreferenceUtilities] cannot find a matching Reader for the given Preference Type.
/// Supported Preference types include: `String, int, double, bool, List<String>` and their nullable versions.
/// If you encounter this, please provide your own Reader with the [ReadPreference] parameter.
class PreferenceReadError<T> extends Error {
  @override
  String toString() {
    return "Error: PreferenceUtilities failed to read $T because it wasn't String, int, double, bool or List<String>."
        "\nPlease provide a reader callback.";
  }
}

/// An error that is thrown when [PreferenceUtilities] cannot find a matching Writer for the given Preference Type.
/// Supported Preference types include: `String, int, double, bool, List<String>` and their nullable versions.
/// If you encounter this, please provide your own Writer with the [WritePreference] parameter.
class PreferenceWriteError<T> extends Error {
  @override
  String toString() {
    return "Error: PreferenceUtilities failed to write $T because it wasn't String, int, double, bool or List<String>."
        "\nPlease provide a writer callback.";
  }
}

/// Adds convenience methods for saving values that might be null.
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
