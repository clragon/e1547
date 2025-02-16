// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credentials.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Credentials _$CredentialsFromJson(Map<String, dynamic> json) {
  return _Credentials.fromJson(json);
}

/// @nodoc
mixin _$Credentials {
  String get username => throw _privateConstructorUsedError;
  @JsonKey(name: 'apikey')
  String get password => throw _privateConstructorUsedError;

  /// Serializes this Credentials to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Credentials
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CredentialsCopyWith<Credentials> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CredentialsCopyWith<$Res> {
  factory $CredentialsCopyWith(
          Credentials value, $Res Function(Credentials) then) =
      _$CredentialsCopyWithImpl<$Res, Credentials>;
  @useResult
  $Res call({String username, @JsonKey(name: 'apikey') String password});
}

/// @nodoc
class _$CredentialsCopyWithImpl<$Res, $Val extends Credentials>
    implements $CredentialsCopyWith<$Res> {
  _$CredentialsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Credentials
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? password = null,
  }) {
    return _then(_value.copyWith(
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CredentialsImplCopyWith<$Res>
    implements $CredentialsCopyWith<$Res> {
  factory _$$CredentialsImplCopyWith(
          _$CredentialsImpl value, $Res Function(_$CredentialsImpl) then) =
      __$$CredentialsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String username, @JsonKey(name: 'apikey') String password});
}

/// @nodoc
class __$$CredentialsImplCopyWithImpl<$Res>
    extends _$CredentialsCopyWithImpl<$Res, _$CredentialsImpl>
    implements _$$CredentialsImplCopyWith<$Res> {
  __$$CredentialsImplCopyWithImpl(
      _$CredentialsImpl _value, $Res Function(_$CredentialsImpl) _then)
      : super(_value, _then);

  /// Create a copy of Credentials
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? password = null,
  }) {
    return _then(_$CredentialsImpl(
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CredentialsImpl extends _Credentials {
  const _$CredentialsImpl(
      {required this.username, @JsonKey(name: 'apikey') required this.password})
      : super._();

  factory _$CredentialsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CredentialsImplFromJson(json);

  @override
  final String username;
  @override
  @JsonKey(name: 'apikey')
  final String password;

  @override
  String toString() {
    return 'Credentials(username: $username, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CredentialsImpl &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, username, password);

  /// Create a copy of Credentials
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CredentialsImplCopyWith<_$CredentialsImpl> get copyWith =>
      __$$CredentialsImplCopyWithImpl<_$CredentialsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CredentialsImplToJson(
      this,
    );
  }
}

abstract class _Credentials extends Credentials {
  const factory _Credentials(
          {required final String username,
          @JsonKey(name: 'apikey') required final String password}) =
      _$CredentialsImpl;
  const _Credentials._() : super._();

  factory _Credentials.fromJson(Map<String, dynamic> json) =
      _$CredentialsImpl.fromJson;

  @override
  String get username;
  @override
  @JsonKey(name: 'apikey')
  String get password;

  /// Create a copy of Credentials
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CredentialsImplCopyWith<_$CredentialsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
