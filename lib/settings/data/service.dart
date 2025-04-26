import 'dart:async';

import 'package:context_plus/context_plus.dart';
import 'package:e1547/settings/data/settings.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: non_constant_identifier_names
final SettingsRef = Ref<SettingsService>();

// This could be backed by Drift.
class SettingsService extends ValueNotifier<Settings> {
  SettingsService(this.prefs) : super(SharedPrefsSettings.read(prefs));

  static Future<SettingsService> init() =>
      SharedPreferences.getInstance().then(SettingsService.new);

  final SharedPreferences prefs;
  Timer? _debounce;

  @override
  set value(Settings value) {
    super.value = value;
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 1000),
      () => value.write(prefs),
    );
  }
}
