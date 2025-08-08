// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Settings {

 AppTheme get theme; bool get showPostInfoBar; int? get identity;
/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsCopyWith<Settings> get copyWith => _$SettingsCopyWithImpl<Settings>(this as Settings, _$identity);

  /// Serializes this Settings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Settings&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.showPostInfoBar, showPostInfoBar) || other.showPostInfoBar == showPostInfoBar)&&(identical(other.identity, identity) || other.identity == identity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,theme,showPostInfoBar,identity);

@override
String toString() {
  return 'Settings(theme: $theme, showPostInfoBar: $showPostInfoBar, identity: $identity)';
}


}

/// @nodoc
abstract mixin class $SettingsCopyWith<$Res>  {
  factory $SettingsCopyWith(Settings value, $Res Function(Settings) _then) = _$SettingsCopyWithImpl;
@useResult
$Res call({
 AppTheme theme, bool showPostInfoBar, int? identity
});




}
/// @nodoc
class _$SettingsCopyWithImpl<$Res>
    implements $SettingsCopyWith<$Res> {
  _$SettingsCopyWithImpl(this._self, this._then);

  final Settings _self;
  final $Res Function(Settings) _then;

/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? theme = null,Object? showPostInfoBar = null,Object? identity = freezed,}) {
  return _then(_self.copyWith(
theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as AppTheme,showPostInfoBar: null == showPostInfoBar ? _self.showPostInfoBar : showPostInfoBar // ignore: cast_nullable_to_non_nullable
as bool,identity: freezed == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}



/// @nodoc
@JsonSerializable()

class _Settings implements Settings {
  const _Settings({required this.theme, required this.showPostInfoBar, this.identity});
  factory _Settings.fromJson(Map<String, dynamic> json) => _$SettingsFromJson(json);

@override final  AppTheme theme;
@override final  bool showPostInfoBar;
@override final  int? identity;

/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SettingsCopyWith<_Settings> get copyWith => __$SettingsCopyWithImpl<_Settings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Settings&&(identical(other.theme, theme) || other.theme == theme)&&(identical(other.showPostInfoBar, showPostInfoBar) || other.showPostInfoBar == showPostInfoBar)&&(identical(other.identity, identity) || other.identity == identity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,theme,showPostInfoBar,identity);

@override
String toString() {
  return 'Settings(theme: $theme, showPostInfoBar: $showPostInfoBar, identity: $identity)';
}


}

/// @nodoc
abstract mixin class _$SettingsCopyWith<$Res> implements $SettingsCopyWith<$Res> {
  factory _$SettingsCopyWith(_Settings value, $Res Function(_Settings) _then) = __$SettingsCopyWithImpl;
@override @useResult
$Res call({
 AppTheme theme, bool showPostInfoBar, int? identity
});




}
/// @nodoc
class __$SettingsCopyWithImpl<$Res>
    implements _$SettingsCopyWith<$Res> {
  __$SettingsCopyWithImpl(this._self, this._then);

  final _Settings _self;
  final $Res Function(_Settings) _then;

/// Create a copy of Settings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? theme = null,Object? showPostInfoBar = null,Object? identity = freezed,}) {
  return _then(_Settings(
theme: null == theme ? _self.theme : theme // ignore: cast_nullable_to_non_nullable
as AppTheme,showPostInfoBar: null == showPostInfoBar ? _self.showPostInfoBar : showPostInfoBar // ignore: cast_nullable_to_non_nullable
as bool,identity: freezed == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
