// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'identity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Identity _$IdentityFromJson(Map<String, dynamic> json) {
  return _Identity.fromJson(json);
}

/// @nodoc
mixin _$Identity {
  int get id => throw _privateConstructorUsedError;
  String get host => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  Map<String, String>? get headers => throw _privateConstructorUsedError;

  /// Serializes this Identity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Identity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IdentityCopyWith<Identity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IdentityCopyWith<$Res> {
  factory $IdentityCopyWith(Identity value, $Res Function(Identity) then) =
      _$IdentityCopyWithImpl<$Res, Identity>;
  @useResult
  $Res call({
    int id,
    String host,
    String? username,
    Map<String, String>? headers,
  });
}

/// @nodoc
class _$IdentityCopyWithImpl<$Res, $Val extends Identity>
    implements $IdentityCopyWith<$Res> {
  _$IdentityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Identity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? host = null,
    Object? username = freezed,
    Object? headers = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            host: null == host
                ? _value.host
                : host // ignore: cast_nullable_to_non_nullable
                      as String,
            username: freezed == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String?,
            headers: freezed == headers
                ? _value.headers
                : headers // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$IdentityImplCopyWith<$Res>
    implements $IdentityCopyWith<$Res> {
  factory _$$IdentityImplCopyWith(
    _$IdentityImpl value,
    $Res Function(_$IdentityImpl) then,
  ) = __$$IdentityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String host,
    String? username,
    Map<String, String>? headers,
  });
}

/// @nodoc
class __$$IdentityImplCopyWithImpl<$Res>
    extends _$IdentityCopyWithImpl<$Res, _$IdentityImpl>
    implements _$$IdentityImplCopyWith<$Res> {
  __$$IdentityImplCopyWithImpl(
    _$IdentityImpl _value,
    $Res Function(_$IdentityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Identity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? host = null,
    Object? username = freezed,
    Object? headers = freezed,
  }) {
    return _then(
      _$IdentityImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        host: null == host
            ? _value.host
            : host // ignore: cast_nullable_to_non_nullable
                  as String,
        username: freezed == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String?,
        headers: freezed == headers
            ? _value._headers
            : headers // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$IdentityImpl implements _Identity {
  const _$IdentityImpl({
    required this.id,
    required this.host,
    required this.username,
    required final Map<String, String>? headers,
  }) : _headers = headers;

  factory _$IdentityImpl.fromJson(Map<String, dynamic> json) =>
      _$$IdentityImplFromJson(json);

  @override
  final int id;
  @override
  final String host;
  @override
  final String? username;
  final Map<String, String>? _headers;
  @override
  Map<String, String>? get headers {
    final value = _headers;
    if (value == null) return null;
    if (_headers is EqualUnmodifiableMapView) return _headers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'Identity(id: $id, host: $host, username: $username, headers: $headers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdentityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.host, host) || other.host == host) &&
            (identical(other.username, username) ||
                other.username == username) &&
            const DeepCollectionEquality().equals(other._headers, _headers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    host,
    username,
    const DeepCollectionEquality().hash(_headers),
  );

  /// Create a copy of Identity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IdentityImplCopyWith<_$IdentityImpl> get copyWith =>
      __$$IdentityImplCopyWithImpl<_$IdentityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IdentityImplToJson(this);
  }
}

abstract class _Identity implements Identity {
  const factory _Identity({
    required final int id,
    required final String host,
    required final String? username,
    required final Map<String, String>? headers,
  }) = _$IdentityImpl;

  factory _Identity.fromJson(Map<String, dynamic> json) =
      _$IdentityImpl.fromJson;

  @override
  int get id;
  @override
  String get host;
  @override
  String? get username;
  @override
  Map<String, String>? get headers;

  /// Create a copy of Identity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IdentityImplCopyWith<_$IdentityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

IdentityRequest _$IdentityRequestFromJson(Map<String, dynamic> json) {
  return _IdentityRequest.fromJson(json);
}

/// @nodoc
mixin _$IdentityRequest {
  String get host => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  Map<String, String>? get headers => throw _privateConstructorUsedError;

  /// Serializes this IdentityRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IdentityRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IdentityRequestCopyWith<IdentityRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IdentityRequestCopyWith<$Res> {
  factory $IdentityRequestCopyWith(
    IdentityRequest value,
    $Res Function(IdentityRequest) then,
  ) = _$IdentityRequestCopyWithImpl<$Res, IdentityRequest>;
  @useResult
  $Res call({String host, String? username, Map<String, String>? headers});
}

/// @nodoc
class _$IdentityRequestCopyWithImpl<$Res, $Val extends IdentityRequest>
    implements $IdentityRequestCopyWith<$Res> {
  _$IdentityRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IdentityRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? host = null,
    Object? username = freezed,
    Object? headers = freezed,
  }) {
    return _then(
      _value.copyWith(
            host: null == host
                ? _value.host
                : host // ignore: cast_nullable_to_non_nullable
                      as String,
            username: freezed == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String?,
            headers: freezed == headers
                ? _value.headers
                : headers // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$IdentityRequestImplCopyWith<$Res>
    implements $IdentityRequestCopyWith<$Res> {
  factory _$$IdentityRequestImplCopyWith(
    _$IdentityRequestImpl value,
    $Res Function(_$IdentityRequestImpl) then,
  ) = __$$IdentityRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String host, String? username, Map<String, String>? headers});
}

/// @nodoc
class __$$IdentityRequestImplCopyWithImpl<$Res>
    extends _$IdentityRequestCopyWithImpl<$Res, _$IdentityRequestImpl>
    implements _$$IdentityRequestImplCopyWith<$Res> {
  __$$IdentityRequestImplCopyWithImpl(
    _$IdentityRequestImpl _value,
    $Res Function(_$IdentityRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IdentityRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? host = null,
    Object? username = freezed,
    Object? headers = freezed,
  }) {
    return _then(
      _$IdentityRequestImpl(
        host: null == host
            ? _value.host
            : host // ignore: cast_nullable_to_non_nullable
                  as String,
        username: freezed == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String?,
        headers: freezed == headers
            ? _value._headers
            : headers // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$IdentityRequestImpl implements _IdentityRequest {
  const _$IdentityRequestImpl({
    required this.host,
    this.username,
    final Map<String, String>? headers,
  }) : _headers = headers;

  factory _$IdentityRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$IdentityRequestImplFromJson(json);

  @override
  final String host;
  @override
  final String? username;
  final Map<String, String>? _headers;
  @override
  Map<String, String>? get headers {
    final value = _headers;
    if (value == null) return null;
    if (_headers is EqualUnmodifiableMapView) return _headers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'IdentityRequest(host: $host, username: $username, headers: $headers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IdentityRequestImpl &&
            (identical(other.host, host) || other.host == host) &&
            (identical(other.username, username) ||
                other.username == username) &&
            const DeepCollectionEquality().equals(other._headers, _headers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    host,
    username,
    const DeepCollectionEquality().hash(_headers),
  );

  /// Create a copy of IdentityRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IdentityRequestImplCopyWith<_$IdentityRequestImpl> get copyWith =>
      __$$IdentityRequestImplCopyWithImpl<_$IdentityRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$IdentityRequestImplToJson(this);
  }
}

abstract class _IdentityRequest implements IdentityRequest {
  const factory _IdentityRequest({
    required final String host,
    final String? username,
    final Map<String, String>? headers,
  }) = _$IdentityRequestImpl;

  factory _IdentityRequest.fromJson(Map<String, dynamic> json) =
      _$IdentityRequestImpl.fromJson;

  @override
  String get host;
  @override
  String? get username;
  @override
  Map<String, String>? get headers;

  /// Create a copy of IdentityRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IdentityRequestImplCopyWith<_$IdentityRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
