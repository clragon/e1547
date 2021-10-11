import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef Serializer<T> = Future<bool> Function(String key, T value);
typedef Deserializer<T> = T? Function(String key);

typedef GetSetting<T> = T? Function(SharedPreferences prefs, String key);
typedef SetSetting<T> = void Function(
    SharedPreferences prefs, String key, T? value);

abstract class SharedPrefsSerializer {
  late final SharedPreferences prefs;
  late final Future<void> initialized;

  SharedPrefsSerializer() {
    initialized = initialize();
  }

  Future<void> initialize() async {
    prefs = await SharedPreferences.getInstance();
  }

  Type typeify<T>() => T;

  bool typeMatch<T, E>() {
    return T == E || typeify<T?>() == E;
  }

  Deserializer<T>? getDeserializer<T>(SharedPreferences prefs) {
    if (typeMatch<String, T>()) {
      return prefs.getString as Deserializer<T>;
    }
    if (typeMatch<int, T>()) {
      return prefs.getInt as Deserializer<T>;
    }
    if (typeMatch<bool, T>()) {
      return prefs.getBool as Deserializer<T>;
    }
    if (T == typeify<List<String>>() || T == typeify<List<String>?>()) {
      return prefs.getStringList as Deserializer<T>;
    }
  }

  Serializer<T>? getSerializer<T>(SharedPreferences prefs) {
    if (typeMatch<String, T>()) {
      return (String key, T? value) => prefs.setString(key, value as String);
    }
    if (typeMatch<int, T>()) {
      return (String key, T? value) => prefs.setInt(key, value as int);
    }
    if (typeMatch<bool, T>()) {
      return (String key, T? value) => prefs.setBool(key, value as bool);
    }
    if (T == typeify<List<String>>() || T == typeify<List<String>?>()) {
      return (String key, T? value) =>
          prefs.setStringList(key, value as List<String>);
    }
  }

  ValueNotifier<T> createSetting<T>({
    required String key,
    required T initial,
    GetSetting<T>? getSetting,
    SetSetting<T>? setSetting,
  }) {
    ValueNotifier<T> setting = ValueNotifier<T>(() {
      T? value;
      if (getSetting == null) {
        Deserializer? deserialize = getDeserializer<T>(prefs);
        value = deserialize?.call(key) as T?;
      } else {
        value = getSetting(prefs, key);
      }
      return value ?? initial;
    }());

    setting.addListener(() async {
      T value = setting.value;
      if (setSetting == null) {
        if (value == null) {
          prefs.remove(key);
        } else {
          Serializer<T>? serialize = getSerializer<T>(prefs);
          await serialize?.call(key, value);
        }
      } else {
        setSetting(prefs, key, value);
      }
    });

    return setting;
  }

  ValueNotifier<T> createStringSetting<T>({
    required String key,
    required T initial,
    List<T>? values,
  }) =>
      createSetting(
        key: key,
        initial: initial,
        getSetting: (prefs, key) {
          String? value = prefs.getString(key);
          return values!
              .singleWhereOrNull((element) => element.toString() == value);
        },
        setSetting: (prefs, key, value) =>
            prefs.setString(key, value.toString()),
      );
}
