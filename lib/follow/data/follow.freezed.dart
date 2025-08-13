// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follow.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Follow {

 int get id; String get tags; String? get title; String? get alias; FollowType get type; int? get latest; int? get unseen; String? get thumbnail; DateTime? get updated;
/// Create a copy of Follow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowCopyWith<Follow> get copyWith => _$FollowCopyWithImpl<Follow>(this as Follow, _$identity);

  /// Serializes this Follow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Follow&&(identical(other.id, id) || other.id == id)&&(identical(other.tags, tags) || other.tags == tags)&&(identical(other.title, title) || other.title == title)&&(identical(other.alias, alias) || other.alias == alias)&&(identical(other.type, type) || other.type == type)&&(identical(other.latest, latest) || other.latest == latest)&&(identical(other.unseen, unseen) || other.unseen == unseen)&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail)&&(identical(other.updated, updated) || other.updated == updated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tags,title,alias,type,latest,unseen,thumbnail,updated);

@override
String toString() {
  return 'Follow(id: $id, tags: $tags, title: $title, alias: $alias, type: $type, latest: $latest, unseen: $unseen, thumbnail: $thumbnail, updated: $updated)';
}


}

/// @nodoc
abstract mixin class $FollowCopyWith<$Res>  {
  factory $FollowCopyWith(Follow value, $Res Function(Follow) _then) = _$FollowCopyWithImpl;
@useResult
$Res call({
 int id, String tags, String? title, String? alias, FollowType type, int? latest, int? unseen, String? thumbnail, DateTime? updated
});




}
/// @nodoc
class _$FollowCopyWithImpl<$Res>
    implements $FollowCopyWith<$Res> {
  _$FollowCopyWithImpl(this._self, this._then);

  final Follow _self;
  final $Res Function(Follow) _then;

/// Create a copy of Follow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tags = null,Object? title = freezed,Object? alias = freezed,Object? type = null,Object? latest = freezed,Object? unseen = freezed,Object? thumbnail = freezed,Object? updated = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,alias: freezed == alias ? _self.alias : alias // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FollowType,latest: freezed == latest ? _self.latest : latest // ignore: cast_nullable_to_non_nullable
as int?,unseen: freezed == unseen ? _self.unseen : unseen // ignore: cast_nullable_to_non_nullable
as int?,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as String?,updated: freezed == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Follow implements Follow {
  const _Follow({required this.id, required this.tags, required this.title, required this.alias, required this.type, required this.latest, required this.unseen, required this.thumbnail, required this.updated});
  factory _Follow.fromJson(Map<String, dynamic> json) => _$FollowFromJson(json);

@override final  int id;
@override final  String tags;
@override final  String? title;
@override final  String? alias;
@override final  FollowType type;
@override final  int? latest;
@override final  int? unseen;
@override final  String? thumbnail;
@override final  DateTime? updated;

/// Create a copy of Follow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowCopyWith<_Follow> get copyWith => __$FollowCopyWithImpl<_Follow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Follow&&(identical(other.id, id) || other.id == id)&&(identical(other.tags, tags) || other.tags == tags)&&(identical(other.title, title) || other.title == title)&&(identical(other.alias, alias) || other.alias == alias)&&(identical(other.type, type) || other.type == type)&&(identical(other.latest, latest) || other.latest == latest)&&(identical(other.unseen, unseen) || other.unseen == unseen)&&(identical(other.thumbnail, thumbnail) || other.thumbnail == thumbnail)&&(identical(other.updated, updated) || other.updated == updated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tags,title,alias,type,latest,unseen,thumbnail,updated);

@override
String toString() {
  return 'Follow(id: $id, tags: $tags, title: $title, alias: $alias, type: $type, latest: $latest, unseen: $unseen, thumbnail: $thumbnail, updated: $updated)';
}


}

/// @nodoc
abstract mixin class _$FollowCopyWith<$Res> implements $FollowCopyWith<$Res> {
  factory _$FollowCopyWith(_Follow value, $Res Function(_Follow) _then) = __$FollowCopyWithImpl;
@override @useResult
$Res call({
 int id, String tags, String? title, String? alias, FollowType type, int? latest, int? unseen, String? thumbnail, DateTime? updated
});




}
/// @nodoc
class __$FollowCopyWithImpl<$Res>
    implements _$FollowCopyWith<$Res> {
  __$FollowCopyWithImpl(this._self, this._then);

  final _Follow _self;
  final $Res Function(_Follow) _then;

/// Create a copy of Follow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tags = null,Object? title = freezed,Object? alias = freezed,Object? type = null,Object? latest = freezed,Object? unseen = freezed,Object? thumbnail = freezed,Object? updated = freezed,}) {
  return _then(_Follow(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,alias: freezed == alias ? _self.alias : alias // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FollowType,latest: freezed == latest ? _self.latest : latest // ignore: cast_nullable_to_non_nullable
as int?,unseen: freezed == unseen ? _self.unseen : unseen // ignore: cast_nullable_to_non_nullable
as int?,thumbnail: freezed == thumbnail ? _self.thumbnail : thumbnail // ignore: cast_nullable_to_non_nullable
as String?,updated: freezed == updated ? _self.updated : updated // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$FollowRequest {

 String get tags; String? get title; String? get alias; FollowType get type;
/// Create a copy of FollowRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowRequestCopyWith<FollowRequest> get copyWith => _$FollowRequestCopyWithImpl<FollowRequest>(this as FollowRequest, _$identity);

  /// Serializes this FollowRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowRequest&&(identical(other.tags, tags) || other.tags == tags)&&(identical(other.title, title) || other.title == title)&&(identical(other.alias, alias) || other.alias == alias)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tags,title,alias,type);

@override
String toString() {
  return 'FollowRequest(tags: $tags, title: $title, alias: $alias, type: $type)';
}


}

/// @nodoc
abstract mixin class $FollowRequestCopyWith<$Res>  {
  factory $FollowRequestCopyWith(FollowRequest value, $Res Function(FollowRequest) _then) = _$FollowRequestCopyWithImpl;
@useResult
$Res call({
 String tags, String? title, String? alias, FollowType type
});




}
/// @nodoc
class _$FollowRequestCopyWithImpl<$Res>
    implements $FollowRequestCopyWith<$Res> {
  _$FollowRequestCopyWithImpl(this._self, this._then);

  final FollowRequest _self;
  final $Res Function(FollowRequest) _then;

/// Create a copy of FollowRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tags = null,Object? title = freezed,Object? alias = freezed,Object? type = null,}) {
  return _then(_self.copyWith(
tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,alias: freezed == alias ? _self.alias : alias // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FollowType,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _FollowRequest implements FollowRequest {
  const _FollowRequest({required this.tags, this.title, this.alias, this.type = FollowType.update});
  factory _FollowRequest.fromJson(Map<String, dynamic> json) => _$FollowRequestFromJson(json);

@override final  String tags;
@override final  String? title;
@override final  String? alias;
@override@JsonKey() final  FollowType type;

/// Create a copy of FollowRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowRequestCopyWith<_FollowRequest> get copyWith => __$FollowRequestCopyWithImpl<_FollowRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowRequest&&(identical(other.tags, tags) || other.tags == tags)&&(identical(other.title, title) || other.title == title)&&(identical(other.alias, alias) || other.alias == alias)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tags,title,alias,type);

@override
String toString() {
  return 'FollowRequest(tags: $tags, title: $title, alias: $alias, type: $type)';
}


}

/// @nodoc
abstract mixin class _$FollowRequestCopyWith<$Res> implements $FollowRequestCopyWith<$Res> {
  factory _$FollowRequestCopyWith(_FollowRequest value, $Res Function(_FollowRequest) _then) = __$FollowRequestCopyWithImpl;
@override @useResult
$Res call({
 String tags, String? title, String? alias, FollowType type
});




}
/// @nodoc
class __$FollowRequestCopyWithImpl<$Res>
    implements _$FollowRequestCopyWith<$Res> {
  __$FollowRequestCopyWithImpl(this._self, this._then);

  final _FollowRequest _self;
  final $Res Function(_FollowRequest) _then;

/// Create a copy of FollowRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tags = null,Object? title = freezed,Object? alias = freezed,Object? type = null,}) {
  return _then(_FollowRequest(
tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,alias: freezed == alias ? _self.alias : alias // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FollowType,
  ));
}


}


/// @nodoc
mixin _$FollowUpdate {

 int get id; String? get tags; String? get title; FollowType? get type;
/// Create a copy of FollowUpdate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowUpdateCopyWith<FollowUpdate> get copyWith => _$FollowUpdateCopyWithImpl<FollowUpdate>(this as FollowUpdate, _$identity);

  /// Serializes this FollowUpdate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowUpdate&&(identical(other.id, id) || other.id == id)&&(identical(other.tags, tags) || other.tags == tags)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tags,title,type);

@override
String toString() {
  return 'FollowUpdate(id: $id, tags: $tags, title: $title, type: $type)';
}


}

/// @nodoc
abstract mixin class $FollowUpdateCopyWith<$Res>  {
  factory $FollowUpdateCopyWith(FollowUpdate value, $Res Function(FollowUpdate) _then) = _$FollowUpdateCopyWithImpl;
@useResult
$Res call({
 int id, String? tags, String? title, FollowType? type
});




}
/// @nodoc
class _$FollowUpdateCopyWithImpl<$Res>
    implements $FollowUpdateCopyWith<$Res> {
  _$FollowUpdateCopyWithImpl(this._self, this._then);

  final FollowUpdate _self;
  final $Res Function(FollowUpdate) _then;

/// Create a copy of FollowUpdate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tags = freezed,Object? title = freezed,Object? type = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,tags: freezed == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FollowType?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _FollowUpdate implements FollowUpdate {
  const _FollowUpdate({required this.id, this.tags, this.title, this.type});
  factory _FollowUpdate.fromJson(Map<String, dynamic> json) => _$FollowUpdateFromJson(json);

@override final  int id;
@override final  String? tags;
@override final  String? title;
@override final  FollowType? type;

/// Create a copy of FollowUpdate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowUpdateCopyWith<_FollowUpdate> get copyWith => __$FollowUpdateCopyWithImpl<_FollowUpdate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowUpdateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowUpdate&&(identical(other.id, id) || other.id == id)&&(identical(other.tags, tags) || other.tags == tags)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,tags,title,type);

@override
String toString() {
  return 'FollowUpdate(id: $id, tags: $tags, title: $title, type: $type)';
}


}

/// @nodoc
abstract mixin class _$FollowUpdateCopyWith<$Res> implements $FollowUpdateCopyWith<$Res> {
  factory _$FollowUpdateCopyWith(_FollowUpdate value, $Res Function(_FollowUpdate) _then) = __$FollowUpdateCopyWithImpl;
@override @useResult
$Res call({
 int id, String? tags, String? title, FollowType? type
});




}
/// @nodoc
class __$FollowUpdateCopyWithImpl<$Res>
    implements _$FollowUpdateCopyWith<$Res> {
  __$FollowUpdateCopyWithImpl(this._self, this._then);

  final _FollowUpdate _self;
  final $Res Function(_FollowUpdate) _then;

/// Create a copy of FollowUpdate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tags = freezed,Object? title = freezed,Object? type = freezed,}) {
  return _then(_FollowUpdate(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,tags: freezed == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as FollowType?,
  ));
}


}

// dart format on
