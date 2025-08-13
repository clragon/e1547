// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostFlag {

 int get id; DateTime get createdAt; int get postId; String get reason; int get creatorId; bool get isResolved; DateTime get updatedAt; bool get isDeletion; PostFlagType get type;
/// Create a copy of PostFlag
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostFlagCopyWith<PostFlag> get copyWith => _$PostFlagCopyWithImpl<PostFlag>(this as PostFlag, _$identity);

  /// Serializes this PostFlag to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostFlag&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.isResolved, isResolved) || other.isResolved == isResolved)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeletion, isDeletion) || other.isDeletion == isDeletion)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,postId,reason,creatorId,isResolved,updatedAt,isDeletion,type);

@override
String toString() {
  return 'PostFlag(id: $id, createdAt: $createdAt, postId: $postId, reason: $reason, creatorId: $creatorId, isResolved: $isResolved, updatedAt: $updatedAt, isDeletion: $isDeletion, type: $type)';
}


}

/// @nodoc
abstract mixin class $PostFlagCopyWith<$Res>  {
  factory $PostFlagCopyWith(PostFlag value, $Res Function(PostFlag) _then) = _$PostFlagCopyWithImpl;
@useResult
$Res call({
 int id, DateTime createdAt, int postId, String reason, int creatorId, bool isResolved, DateTime updatedAt, bool isDeletion, PostFlagType type
});




}
/// @nodoc
class _$PostFlagCopyWithImpl<$Res>
    implements $PostFlagCopyWith<$Res> {
  _$PostFlagCopyWithImpl(this._self, this._then);

  final PostFlag _self;
  final $Res Function(PostFlag) _then;

/// Create a copy of PostFlag
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? postId = null,Object? reason = null,Object? creatorId = null,Object? isResolved = null,Object? updatedAt = null,Object? isDeletion = null,Object? type = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,isResolved: null == isResolved ? _self.isResolved : isResolved // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeletion: null == isDeletion ? _self.isDeletion : isDeletion // ignore: cast_nullable_to_non_nullable
as bool,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PostFlagType,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _PostFlag implements PostFlag {
  const _PostFlag({required this.id, required this.createdAt, required this.postId, required this.reason, required this.creatorId, required this.isResolved, required this.updatedAt, required this.isDeletion, required this.type});
  factory _PostFlag.fromJson(Map<String, dynamic> json) => _$PostFlagFromJson(json);

@override final  int id;
@override final  DateTime createdAt;
@override final  int postId;
@override final  String reason;
@override final  int creatorId;
@override final  bool isResolved;
@override final  DateTime updatedAt;
@override final  bool isDeletion;
@override final  PostFlagType type;

/// Create a copy of PostFlag
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostFlagCopyWith<_PostFlag> get copyWith => __$PostFlagCopyWithImpl<_PostFlag>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostFlagToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostFlag&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.isResolved, isResolved) || other.isResolved == isResolved)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeletion, isDeletion) || other.isDeletion == isDeletion)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,postId,reason,creatorId,isResolved,updatedAt,isDeletion,type);

@override
String toString() {
  return 'PostFlag(id: $id, createdAt: $createdAt, postId: $postId, reason: $reason, creatorId: $creatorId, isResolved: $isResolved, updatedAt: $updatedAt, isDeletion: $isDeletion, type: $type)';
}


}

/// @nodoc
abstract mixin class _$PostFlagCopyWith<$Res> implements $PostFlagCopyWith<$Res> {
  factory _$PostFlagCopyWith(_PostFlag value, $Res Function(_PostFlag) _then) = __$PostFlagCopyWithImpl;
@override @useResult
$Res call({
 int id, DateTime createdAt, int postId, String reason, int creatorId, bool isResolved, DateTime updatedAt, bool isDeletion, PostFlagType type
});




}
/// @nodoc
class __$PostFlagCopyWithImpl<$Res>
    implements _$PostFlagCopyWith<$Res> {
  __$PostFlagCopyWithImpl(this._self, this._then);

  final _PostFlag _self;
  final $Res Function(_PostFlag) _then;

/// Create a copy of PostFlag
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? postId = null,Object? reason = null,Object? creatorId = null,Object? isResolved = null,Object? updatedAt = null,Object? isDeletion = null,Object? type = null,}) {
  return _then(_PostFlag(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as int,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as int,isResolved: null == isResolved ? _self.isResolved : isResolved // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,isDeletion: null == isDeletion ? _self.isDeletion : isDeletion // ignore: cast_nullable_to_non_nullable
as bool,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PostFlagType,
  ));
}


}

// dart format on
