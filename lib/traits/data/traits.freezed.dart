// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'traits.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Traits {

 int get id; int? get userId; List<String> get denylist; String get homeTags; String? get avatar; int? get perPage;
/// Create a copy of Traits
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TraitsCopyWith<Traits> get copyWith => _$TraitsCopyWithImpl<Traits>(this as Traits, _$identity);

  /// Serializes this Traits to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Traits&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other.denylist, denylist)&&(identical(other.homeTags, homeTags) || other.homeTags == homeTags)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.perPage, perPage) || other.perPage == perPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,const DeepCollectionEquality().hash(denylist),homeTags,avatar,perPage);

@override
String toString() {
  return 'Traits(id: $id, userId: $userId, denylist: $denylist, homeTags: $homeTags, avatar: $avatar, perPage: $perPage)';
}


}

/// @nodoc
abstract mixin class $TraitsCopyWith<$Res>  {
  factory $TraitsCopyWith(Traits value, $Res Function(Traits) _then) = _$TraitsCopyWithImpl;
@useResult
$Res call({
 int id, int? userId, List<String> denylist, String homeTags, String? avatar, int? perPage
});




}
/// @nodoc
class _$TraitsCopyWithImpl<$Res>
    implements $TraitsCopyWith<$Res> {
  _$TraitsCopyWithImpl(this._self, this._then);

  final Traits _self;
  final $Res Function(Traits) _then;

/// Create a copy of Traits
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = freezed,Object? denylist = null,Object? homeTags = null,Object? avatar = freezed,Object? perPage = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,denylist: null == denylist ? _self.denylist : denylist // ignore: cast_nullable_to_non_nullable
as List<String>,homeTags: null == homeTags ? _self.homeTags : homeTags // ignore: cast_nullable_to_non_nullable
as String,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,perPage: freezed == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}



/// @nodoc
@JsonSerializable()

class _Traits implements Traits {
  const _Traits({required this.id, required this.userId, required final  List<String> denylist, required this.homeTags, required this.avatar, required this.perPage}): _denylist = denylist;
  factory _Traits.fromJson(Map<String, dynamic> json) => _$TraitsFromJson(json);

@override final  int id;
@override final  int? userId;
 final  List<String> _denylist;
@override List<String> get denylist {
  if (_denylist is EqualUnmodifiableListView) return _denylist;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_denylist);
}

@override final  String homeTags;
@override final  String? avatar;
@override final  int? perPage;

/// Create a copy of Traits
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TraitsCopyWith<_Traits> get copyWith => __$TraitsCopyWithImpl<_Traits>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TraitsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Traits&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other._denylist, _denylist)&&(identical(other.homeTags, homeTags) || other.homeTags == homeTags)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.perPage, perPage) || other.perPage == perPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,const DeepCollectionEquality().hash(_denylist),homeTags,avatar,perPage);

@override
String toString() {
  return 'Traits(id: $id, userId: $userId, denylist: $denylist, homeTags: $homeTags, avatar: $avatar, perPage: $perPage)';
}


}

/// @nodoc
abstract mixin class _$TraitsCopyWith<$Res> implements $TraitsCopyWith<$Res> {
  factory _$TraitsCopyWith(_Traits value, $Res Function(_Traits) _then) = __$TraitsCopyWithImpl;
@override @useResult
$Res call({
 int id, int? userId, List<String> denylist, String homeTags, String? avatar, int? perPage
});




}
/// @nodoc
class __$TraitsCopyWithImpl<$Res>
    implements _$TraitsCopyWith<$Res> {
  __$TraitsCopyWithImpl(this._self, this._then);

  final _Traits _self;
  final $Res Function(_Traits) _then;

/// Create a copy of Traits
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = freezed,Object? denylist = null,Object? homeTags = null,Object? avatar = freezed,Object? perPage = freezed,}) {
  return _then(_Traits(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,denylist: null == denylist ? _self._denylist : denylist // ignore: cast_nullable_to_non_nullable
as List<String>,homeTags: null == homeTags ? _self.homeTags : homeTags // ignore: cast_nullable_to_non_nullable
as String,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,perPage: freezed == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$TraitsRequest {

 int get identity; int? get userId; List<String> get denylist; String get homeTags; String? get avatar; int? get perPage;
/// Create a copy of TraitsRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TraitsRequestCopyWith<TraitsRequest> get copyWith => _$TraitsRequestCopyWithImpl<TraitsRequest>(this as TraitsRequest, _$identity);

  /// Serializes this TraitsRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TraitsRequest&&(identical(other.identity, identity) || other.identity == identity)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other.denylist, denylist)&&(identical(other.homeTags, homeTags) || other.homeTags == homeTags)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.perPage, perPage) || other.perPage == perPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,identity,userId,const DeepCollectionEquality().hash(denylist),homeTags,avatar,perPage);

@override
String toString() {
  return 'TraitsRequest(identity: $identity, userId: $userId, denylist: $denylist, homeTags: $homeTags, avatar: $avatar, perPage: $perPage)';
}


}

/// @nodoc
abstract mixin class $TraitsRequestCopyWith<$Res>  {
  factory $TraitsRequestCopyWith(TraitsRequest value, $Res Function(TraitsRequest) _then) = _$TraitsRequestCopyWithImpl;
@useResult
$Res call({
 int identity, int? userId, List<String> denylist, String homeTags, String? avatar, int? perPage
});




}
/// @nodoc
class _$TraitsRequestCopyWithImpl<$Res>
    implements $TraitsRequestCopyWith<$Res> {
  _$TraitsRequestCopyWithImpl(this._self, this._then);

  final TraitsRequest _self;
  final $Res Function(TraitsRequest) _then;

/// Create a copy of TraitsRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? identity = null,Object? userId = freezed,Object? denylist = null,Object? homeTags = null,Object? avatar = freezed,Object? perPage = freezed,}) {
  return _then(_self.copyWith(
identity: null == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as int,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,denylist: null == denylist ? _self.denylist : denylist // ignore: cast_nullable_to_non_nullable
as List<String>,homeTags: null == homeTags ? _self.homeTags : homeTags // ignore: cast_nullable_to_non_nullable
as String,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,perPage: freezed == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}



/// @nodoc
@JsonSerializable()

class _TraitsRequest implements TraitsRequest {
  const _TraitsRequest({required this.identity, this.userId, final  List<String> denylist = const [], this.homeTags = '', this.avatar, this.perPage}): _denylist = denylist;
  factory _TraitsRequest.fromJson(Map<String, dynamic> json) => _$TraitsRequestFromJson(json);

@override final  int identity;
@override final  int? userId;
 final  List<String> _denylist;
@override@JsonKey() List<String> get denylist {
  if (_denylist is EqualUnmodifiableListView) return _denylist;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_denylist);
}

@override@JsonKey() final  String homeTags;
@override final  String? avatar;
@override final  int? perPage;

/// Create a copy of TraitsRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TraitsRequestCopyWith<_TraitsRequest> get copyWith => __$TraitsRequestCopyWithImpl<_TraitsRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TraitsRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TraitsRequest&&(identical(other.identity, identity) || other.identity == identity)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other._denylist, _denylist)&&(identical(other.homeTags, homeTags) || other.homeTags == homeTags)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&(identical(other.perPage, perPage) || other.perPage == perPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,identity,userId,const DeepCollectionEquality().hash(_denylist),homeTags,avatar,perPage);

@override
String toString() {
  return 'TraitsRequest(identity: $identity, userId: $userId, denylist: $denylist, homeTags: $homeTags, avatar: $avatar, perPage: $perPage)';
}


}

/// @nodoc
abstract mixin class _$TraitsRequestCopyWith<$Res> implements $TraitsRequestCopyWith<$Res> {
  factory _$TraitsRequestCopyWith(_TraitsRequest value, $Res Function(_TraitsRequest) _then) = __$TraitsRequestCopyWithImpl;
@override @useResult
$Res call({
 int identity, int? userId, List<String> denylist, String homeTags, String? avatar, int? perPage
});




}
/// @nodoc
class __$TraitsRequestCopyWithImpl<$Res>
    implements _$TraitsRequestCopyWith<$Res> {
  __$TraitsRequestCopyWithImpl(this._self, this._then);

  final _TraitsRequest _self;
  final $Res Function(_TraitsRequest) _then;

/// Create a copy of TraitsRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? identity = null,Object? userId = freezed,Object? denylist = null,Object? homeTags = null,Object? avatar = freezed,Object? perPage = freezed,}) {
  return _then(_TraitsRequest(
identity: null == identity ? _self.identity : identity // ignore: cast_nullable_to_non_nullable
as int,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int?,denylist: null == denylist ? _self._denylist : denylist // ignore: cast_nullable_to_non_nullable
as List<String>,homeTags: null == homeTags ? _self.homeTags : homeTags // ignore: cast_nullable_to_non_nullable
as String,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,perPage: freezed == perPage ? _self.perPage : perPage // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
