// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'identity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Identity {

 int get id; String get host; String? get username; Map<String, String>? get headers;
/// Create a copy of Identity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdentityCopyWith<Identity> get copyWith => _$IdentityCopyWithImpl<Identity>(this as Identity, _$identity);

  /// Serializes this Identity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Identity&&(identical(other.id, id) || other.id == id)&&(identical(other.host, host) || other.host == host)&&(identical(other.username, username) || other.username == username)&&const DeepCollectionEquality().equals(other.headers, headers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,host,username,const DeepCollectionEquality().hash(headers));

@override
String toString() {
  return 'Identity(id: $id, host: $host, username: $username, headers: $headers)';
}


}

/// @nodoc
abstract mixin class $IdentityCopyWith<$Res>  {
  factory $IdentityCopyWith(Identity value, $Res Function(Identity) _then) = _$IdentityCopyWithImpl;
@useResult
$Res call({
 int id, String host, String? username, Map<String, String>? headers
});




}
/// @nodoc
class _$IdentityCopyWithImpl<$Res>
    implements $IdentityCopyWith<$Res> {
  _$IdentityCopyWithImpl(this._self, this._then);

  final Identity _self;
  final $Res Function(Identity) _then;

/// Create a copy of Identity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? host = null,Object? username = freezed,Object? headers = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,headers: freezed == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Identity implements Identity {
  const _Identity({required this.id, required this.host, required this.username, required final  Map<String, String>? headers}): _headers = headers;
  factory _Identity.fromJson(Map<String, dynamic> json) => _$IdentityFromJson(json);

@override final  int id;
@override final  String host;
@override final  String? username;
 final  Map<String, String>? _headers;
@override Map<String, String>? get headers {
  final value = _headers;
  if (value == null) return null;
  if (_headers is EqualUnmodifiableMapView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of Identity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IdentityCopyWith<_Identity> get copyWith => __$IdentityCopyWithImpl<_Identity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IdentityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Identity&&(identical(other.id, id) || other.id == id)&&(identical(other.host, host) || other.host == host)&&(identical(other.username, username) || other.username == username)&&const DeepCollectionEquality().equals(other._headers, _headers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,host,username,const DeepCollectionEquality().hash(_headers));

@override
String toString() {
  return 'Identity(id: $id, host: $host, username: $username, headers: $headers)';
}


}

/// @nodoc
abstract mixin class _$IdentityCopyWith<$Res> implements $IdentityCopyWith<$Res> {
  factory _$IdentityCopyWith(_Identity value, $Res Function(_Identity) _then) = __$IdentityCopyWithImpl;
@override @useResult
$Res call({
 int id, String host, String? username, Map<String, String>? headers
});




}
/// @nodoc
class __$IdentityCopyWithImpl<$Res>
    implements _$IdentityCopyWith<$Res> {
  __$IdentityCopyWithImpl(this._self, this._then);

  final _Identity _self;
  final $Res Function(_Identity) _then;

/// Create a copy of Identity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? host = null,Object? username = freezed,Object? headers = freezed,}) {
  return _then(_Identity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,headers: freezed == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}


}


/// @nodoc
mixin _$IdentityRequest {

 String get host; String? get username; Map<String, String>? get headers;
/// Create a copy of IdentityRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdentityRequestCopyWith<IdentityRequest> get copyWith => _$IdentityRequestCopyWithImpl<IdentityRequest>(this as IdentityRequest, _$identity);

  /// Serializes this IdentityRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IdentityRequest&&(identical(other.host, host) || other.host == host)&&(identical(other.username, username) || other.username == username)&&const DeepCollectionEquality().equals(other.headers, headers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,host,username,const DeepCollectionEquality().hash(headers));

@override
String toString() {
  return 'IdentityRequest(host: $host, username: $username, headers: $headers)';
}


}

/// @nodoc
abstract mixin class $IdentityRequestCopyWith<$Res>  {
  factory $IdentityRequestCopyWith(IdentityRequest value, $Res Function(IdentityRequest) _then) = _$IdentityRequestCopyWithImpl;
@useResult
$Res call({
 String host, String? username, Map<String, String>? headers
});




}
/// @nodoc
class _$IdentityRequestCopyWithImpl<$Res>
    implements $IdentityRequestCopyWith<$Res> {
  _$IdentityRequestCopyWithImpl(this._self, this._then);

  final IdentityRequest _self;
  final $Res Function(IdentityRequest) _then;

/// Create a copy of IdentityRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? host = null,Object? username = freezed,Object? headers = freezed,}) {
  return _then(_self.copyWith(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,headers: freezed == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _IdentityRequest implements IdentityRequest {
  const _IdentityRequest({required this.host, this.username, final  Map<String, String>? headers}): _headers = headers;
  factory _IdentityRequest.fromJson(Map<String, dynamic> json) => _$IdentityRequestFromJson(json);

@override final  String host;
@override final  String? username;
 final  Map<String, String>? _headers;
@override Map<String, String>? get headers {
  final value = _headers;
  if (value == null) return null;
  if (_headers is EqualUnmodifiableMapView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of IdentityRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IdentityRequestCopyWith<_IdentityRequest> get copyWith => __$IdentityRequestCopyWithImpl<_IdentityRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IdentityRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IdentityRequest&&(identical(other.host, host) || other.host == host)&&(identical(other.username, username) || other.username == username)&&const DeepCollectionEquality().equals(other._headers, _headers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,host,username,const DeepCollectionEquality().hash(_headers));

@override
String toString() {
  return 'IdentityRequest(host: $host, username: $username, headers: $headers)';
}


}

/// @nodoc
abstract mixin class _$IdentityRequestCopyWith<$Res> implements $IdentityRequestCopyWith<$Res> {
  factory _$IdentityRequestCopyWith(_IdentityRequest value, $Res Function(_IdentityRequest) _then) = __$IdentityRequestCopyWithImpl;
@override @useResult
$Res call({
 String host, String? username, Map<String, String>? headers
});




}
/// @nodoc
class __$IdentityRequestCopyWithImpl<$Res>
    implements _$IdentityRequestCopyWith<$Res> {
  __$IdentityRequestCopyWithImpl(this._self, this._then);

  final _IdentityRequest _self;
  final $Res Function(_IdentityRequest) _then;

/// Create a copy of IdentityRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? host = null,Object? username = freezed,Object? headers = freezed,}) {
  return _then(_IdentityRequest(
host: null == host ? _self.host : host // ignore: cast_nullable_to_non_nullable
as String,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,headers: freezed == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}


}

// dart format on
