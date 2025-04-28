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
  }) = _Settings;

  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);
}

extension SharedPrefsSettings on Settings {
  static const String _themeKey = 'theme';
  static const String _showPostInfoBarKey = 'show_post_info_bar';

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
      );

  void write(SharedPreferences prefs) {
    PreferenceAdapter.enumWriter(prefs, _themeKey, theme);
    PreferenceAdapter.writeSetting(
      prefs: prefs,
      key: _showPostInfoBarKey,
      value: showPostInfoBar,
    );
  }
}
