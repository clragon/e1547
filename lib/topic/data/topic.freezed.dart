// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'topic.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Topic {

 int get id; int get creatorId; String get creator; DateTime get createdAt; int get updaterId; String get updater; DateTime get updatedAt; String get title; int get responseCount; bool get sticky; bool get locked; bool get hidden; int get categoryId;
/// Create a copy of Topic
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TopicCopyWith<Topic> get copyWith => _$TopicCopyWithImpl<Topic>(this as Topic, _$identity);

  /// Serializes this Topic to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Topic&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updaterId, updaterId) || other.updaterId == updaterId)&&(identical(other.updater, updater) || other.updater == updater)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.responseCount, responseCount) || other.responseCount == responseCount)&&(identical(other.sticky, sticky) || other.sticky == sticky)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,creator,createdAt,updaterId,updater,updatedAt,title,responseCount,sticky,locked,hidden,categoryId);

@override
String toString() {
  return 'Topic(id: $id, creatorId: $creatorId, creator: $creator, createdAt: $createdAt, updaterId: $updaterId, updater: $updater, updatedAt: $updatedAt, title: $title, responseCount: $responseCount, sticky: $sticky, locked: $locked, hidden: $hidden, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class $TopicCopyWith<$Res>  {
  factory $TopicCopyWith(Topic value, $Res Function(Topic) _then) = _$TopicCopyWithImpl;
@useResult
$Res call({
 int id, int creatorId, String creator, DateTime createdAt, int updaterId, String updater, DateTime updatedAt, String title, int responseCount, bool sticky, bool locked, bool hidden, int categoryId
});




}
/// @nodoc
class _$TopicCopyWithImpl<$Res>
    implements $TopicCopyWith<$Res> {
  _$TopicCopyWithImpl(this._self, this._then);

  final Topic _self;
  final $Res Function(Topic) _then;

/// Create a copy of Topic
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? creatorId = null,Object? creator = null,Object? createdAt = null,Object? updaterId = null,Object? updater = null,Object? updatedAt = null,Object? title = null,Object? responseCount = null,Object? sticky = null,Object? locked = null,Object? hidden = null,Object? categoryId = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updaterId: null == updaterId ? _self.updaterId : updaterId // ignore: cast_nullable_to_non_nullable
as int,updater: null == updater ? _self.updater : updater // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,responseCount: null == responseCount ? _self.responseCount : responseCount // ignore: cast_nullable_to_non_nullable
as int,sticky: null == sticky ? _self.sticky : sticky // ignore: cast_nullable_to_non_nullable
as bool,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Topic implements Topic {
  const _Topic({required this.id, required this.creatorId, required this.creator, required this.createdAt, required this.updaterId, required this.updater, required this.updatedAt, required this.title, required this.responseCount, required this.sticky, required this.locked, required this.hidden, required this.categoryId});
  factory _Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);

@override final  int id;
@override final  int creatorId;
@override final  String creator;
@override final  DateTime createdAt;
@override final  int updaterId;
@override final  String updater;
@override final  DateTime updatedAt;
@override final  String title;
@override final  int responseCount;
@override final  bool sticky;
@override final  bool locked;
@override final  bool hidden;
@override final  int categoryId;

/// Create a copy of Topic
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TopicCopyWith<_Topic> get copyWith => __$TopicCopyWithImpl<_Topic>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TopicToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Topic&&(identical(other.id, id) || other.id == id)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updaterId, updaterId) || other.updaterId == updaterId)&&(identical(other.updater, updater) || other.updater == updater)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.title, title) || other.title == title)&&(identical(other.responseCount, responseCount) || other.responseCount == responseCount)&&(identical(other.sticky, sticky) || other.sticky == sticky)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.hidden, hidden) || other.hidden == hidden)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,creatorId,creator,createdAt,updaterId,updater,updatedAt,title,responseCount,sticky,locked,hidden,categoryId);

@override
String toString() {
  return 'Topic(id: $id, creatorId: $creatorId, creator: $creator, createdAt: $createdAt, updaterId: $updaterId, updater: $updater, updatedAt: $updatedAt, title: $title, responseCount: $responseCount, sticky: $sticky, locked: $locked, hidden: $hidden, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class _$TopicCopyWith<$Res> implements $TopicCopyWith<$Res> {
  factory _$TopicCopyWith(_Topic value, $Res Function(_Topic) _then) = __$TopicCopyWithImpl;
@override @useResult
$Res call({
 int id, int creatorId, String creator, DateTime createdAt, int updaterId, String updater, DateTime updatedAt, String title, int responseCount, bool sticky, bool locked, bool hidden, int categoryId
});




}
/// @nodoc
class __$TopicCopyWithImpl<$Res>
    implements _$TopicCopyWith<$Res> {
  __$TopicCopyWithImpl(this._self, this._then);

  final _Topic _self;
  final $Res Function(_Topic) _then;

/// Create a copy of Topic
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? creatorId = null,Object? creator = null,Object? createdAt = null,Object? updaterId = null,Object? updater = null,Object? updatedAt = null,Object? title = null,Object? responseCount = null,Object? sticky = null,Object? locked = null,Object? hidden = null,Object? categoryId = null,}) {
  return _then(_Topic(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,creator: null == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updaterId: null == updaterId ? _self.updaterId : updaterId // ignore: cast_nullable_to_non_nullable
as int,updater: null == updater ? _self.updater : updater // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,responseCount: null == responseCount ? _self.responseCount : responseCount // ignore: cast_nullable_to_non_nullable
as int,sticky: null == sticky ? _self.sticky : sticky // ignore: cast_nullable_to_non_nullable
as bool,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,hidden: null == hidden ? _self.hidden : hidden // ignore: cast_nullable_to_non_nullable
as bool,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
