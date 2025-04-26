// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Settings _$SettingsFromJson(Map<String, dynamic> json) => _Settings(
      theme: $enumDecode(_$AppThemeEnumMap, json['theme']),
    );

Map<String, dynamic> _$SettingsToJson(_Settings instance) => <String, dynamic>{
      'theme': _$AppThemeEnumMap[instance.theme]!,
    };

const _$AppThemeEnumMap = {
  AppTheme.dark: 'dark',
  AppTheme.amoled: 'amoled',
  AppTheme.light: 'light',
  AppTheme.blue: 'blue',
};
