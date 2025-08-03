// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reply.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Reply {

 int get id; int get creatorId; String get creator; DateTime get createdAt; int? get updaterId; String? get updater; DateTime get updatedAt; String get body; int get topicId; WarningType? get warning; bool get hidden;
/// Create a copy of Reply
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReplyCopyWith<Reply> get copyWith => _$ReplyCopyWithImpl<Reply>(this as Reply, _$identity);

  /// Serializes this Reply to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Reply&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updaterId, updaterId) || other.updaterId == updaterId)&&(identical(other.updater, updater) || other.updater == updater)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.body, body) || other.body == body)&&(identical(other.topicId, topicId) || other.topicId == topicId)&&(identical(other.warning, warning) || other.warning == warning)&&(identical(other.hidden, hidden) || other.hidden == hidden));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,creator,createdAt,updaterId,updater,updatedAt,body,topicId,warning,hidden);

@override
String toString() {
  return 'Reply(id: $id, creatorId: $creatorId, creator: $creator, createdAt: $createdAt, updaterId: $updaterId, updater: $updater, updatedAt: $updatedAt, body: $body, topicId: $topicId, warning: $warning, hidden: $hidden)';
}


}

/// @nodoc
abstract mixin class $ReplyCopyWith<$Res>  {
  factory $ReplyCopyWith(Reply value, $Res Function(Reply) _then) = _$ReplyCopyWithImpl;
@useResult
$Res call({
 int id, int creatorId, String creator, DateTime createdAt, int? updaterId, String? updater, DateTime updatedAt, String body, int topicId, WarningType? warning, bool hidden
});




}
/// @nodoc
class _$ReplyCopyWithImpl<$Res>
    implements $ReplyCopyWith<$Res> {
  _$ReplyCopyWithImpl(this._self, this._then);

  final Reply _self;
  final $Res Function(Reply) _then;

/// Create a copy of Reply
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creatorId = null,Object? creator = null,Object? createdAt = null,Object? updaterId = freezed,Object? updater = freezed,Object? updatedAt = null,Object? body = null,Object? topicId = null,Object? warning = freezed,Object? hidden = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updaterId: freezed == updaterId ? _self.updaterId : updaterId // ignore: cast_nullable_to_non_nullable
as int?,updater: freezed == updater ? _self.updater : updater // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,topicId: null == topicId ? _self.topicId : topicId // ignore: cast_nullable_to_non_nullable
as int,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as WarningType?,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}



/// @nodoc
@JsonSerializable()

class _Reply implements Reply {
  const _Reply({required this.id, required this.creatorId, required this.creator, required this.createdAt, required this.updaterId, required this.updater, required this.updatedAt, required this.body, required this.topicId, required this.warning, required this.hidden});
  factory _Reply.fromJson(Map<String, dynamic> json) => _$ReplyFromJson(json);

@override final  int id;
@override final  int creatorId;
@override final  String creator;
@override final  DateTime createdAt;
@override final  int? updaterId;
@override final  String? updater;
@override final  DateTime updatedAt;
@override final  String body;
@override final  int topicId;
@override final  WarningType? warning;
@override final  bool hidden;

/// Create a copy of Reply
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReplyCopyWith<_Reply> get copyWith => __$ReplyCopyWithImpl<_Reply>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReplyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reply&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updaterId, updaterId) || other.updaterId == updaterId)&&(identical(other.updater, updater) || other.updater == updater)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.body, body) || other.body == body)&&(identical(other.topicId, topicId) || other.topicId == topicId)&&(identical(other.warning, warning) || other.warning == warning)&&(identical(other.hidden, hidden) || other.hidden == hidden));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,creator,createdAt,updaterId,updater,updatedAt,body,topicId,warning,hidden);

@override
String toString() {
  return 'Reply(id: $id, creatorId: $creatorId, creator: $creator, createdAt: $createdAt, updaterId: $updaterId, updater: $updater, updatedAt: $updatedAt, body: $body, topicId: $topicId, warning: $warning, hidden: $hidden)';
}


}

/// @nodoc
abstract mixin class _$ReplyCopyWith<$Res> implements $ReplyCopyWith<$Res> {
  factory _$ReplyCopyWith(_Reply value, $Res Function(_Reply) _then) = __$ReplyCopyWithImpl;
@override @useResult
$Res call({
 int id, int creatorId, String creator, DateTime createdAt, int? updaterId, String? updater, DateTime updatedAt, String body, int topicId, WarningType? warning, bool hidden
});




}
/// @nodoc
class __$ReplyCopyWithImpl<$Res>
    implements _$ReplyCopyWith<$Res> {
  __$ReplyCopyWithImpl(this._self, this._then);

  final _Reply _self;
  final $Res Function(_Reply) _then;

/// Create a copy of Reply
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creatorId = null,Object? creator = null,Object? createdAt = null,Object? updaterId = freezed,Object? updater = freezed,Object? updatedAt = null,Object? body = null,Object? topicId = null,Object? warning = freezed,Object? hidden = null,}) {
  return _then(_Reply(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updaterId: freezed == updaterId ? _self.updaterId : updaterId // ignore: cast_nullable_to_non_nullable
as int?,updater: freezed == updater ? _self.updater : updater // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,topicId: null == topicId ? _self.topicId : topicId // ignore: cast_nullable_to_non_nullable
as int,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as WarningType?,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
