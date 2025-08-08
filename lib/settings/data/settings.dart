import 'package:e1547/settings/data/preferences/preference_adapter.dart';
import 'package:e1547/theme/data/theme.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings.freezed.dart';
part 'settings.g.dart';

@freezed
abstract class Settings with _$Settings {
  const factory Settings({
    required AppTheme theme,
    required bool showPostInfoBar,
    int? identity,
  }) = _Settings;

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);
}

extension SharedPrefsSettings on Settings {
  static const String _themeKey = 'theme';
  static const String _showPostInfoBarKey = 'show_post_info_bar';
  static const String _identityKey = 'identity';

  static Settings read(SharedPreferences prefs) => Settings(
    theme: PreferenceAdapter.readSetting<AppTheme>(
      prefs: prefs,
      key: _themeKey,
      initialValue: AppTheme.dark,
      read: PreferenceAdapter.enumReader(AppTheme.values),
    ),
    showPostInfoBar: PreferenceAdapter.readSetting<bool>(
      prefs: prefs,
      key: _showPostInfoBarKey,
      initialValue: false,
    ),
    identity: PreferenceAdapter.readSetting<int?>(
      prefs: prefs,
      key: _identityKey,
      initialValue: null,
    ),
  );

  void write(SharedPreferences prefs) {
    PreferenceAdapter.enumWriter(prefs, _themeKey, theme);
    PreferenceAdapter.writeSetting(
      prefs: prefs,
      key: _showPostInfoBarKey,
      value: showPostInfoBar,
    );
    PreferenceAdapter.writeSetting(
      prefs: prefs,
      key: _identityKey,
      value: identity,
    );
  }
}
