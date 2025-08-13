// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pool.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Pool {

 int get id; String get name; DateTime get createdAt; DateTime get updatedAt; String get description; List<int> get postIds; int get postCount; bool get active;
/// Create a copy of Pool
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PoolCopyWith<Pool> get copyWith => _$PoolCopyWithImpl<Pool>(this as Pool, _$identity);

  /// Serializes this Pool to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Pool&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.postIds, postIds)&&(identical(other.postCount, postCount) || other.postCount == postCount)&&(identical(other.active, active) || other.active == active));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,createdAt,updatedAt,description,const DeepCollectionEquality().hash(postIds),postCount,active);

@override
String toString() {
  return 'Pool(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, postIds: $postIds, postCount: $postCount, active: $active)';
}


}

/// @nodoc
abstract mixin class $PoolCopyWith<$Res>  {
  factory $PoolCopyWith(Pool value, $Res Function(Pool) _then) = _$PoolCopyWithImpl;
@useResult
$Res call({
 int id, String name, DateTime createdAt, DateTime updatedAt, String description, List<int> postIds, int postCount, bool active
});




}
/// @nodoc
class _$PoolCopyWithImpl<$Res>
    implements $PoolCopyWith<$Res> {
  _$PoolCopyWithImpl(this._self, this._then);

  final Pool _self;
  final $Res Function(Pool) _then;

/// Create a copy of Pool
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? createdAt = null,Object? updatedAt = null,Object? description = null,Object? postIds = null,Object? postCount = null,Object? active = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,postIds: null == postIds ? _self.postIds : postIds // ignore: cast_nullable_to_non_nullable
as List<int>,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Pool implements Pool {
  const _Pool({required this.id, required this.name, required this.createdAt, required this.updatedAt, required this.description, required final  List<int> postIds, required this.postCount, required this.active}): _postIds = postIds;
  factory _Pool.fromJson(Map<String, dynamic> json) => _$PoolFromJson(json);

@override final  int id;
@override final  String name;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String description;
 final  List<int> _postIds;
@override List<int> get postIds {
  if (_postIds is EqualUnmodifiableListView) return _postIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_postIds);
}

@override final  int postCount;
@override final  bool active;

/// Create a copy of Pool
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PoolCopyWith<_Pool> get copyWith => __$PoolCopyWithImpl<_Pool>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PoolToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pool&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._postIds, _postIds)&&(identical(other.postCount, postCount) || other.postCount == postCount)&&(identical(other.active, active) || other.active == active));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,createdAt,updatedAt,description,const DeepCollectionEquality().hash(_postIds),postCount,active);

@override
String toString() {
  return 'Pool(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, postIds: $postIds, postCount: $postCount, active: $active)';
}


}

/// @nodoc
abstract mixin class _$PoolCopyWith<$Res> implements $PoolCopyWith<$Res> {
  factory _$PoolCopyWith(_Pool value, $Res Function(_Pool) _then) = __$PoolCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, DateTime createdAt, DateTime updatedAt, String description, List<int> postIds, int postCount, bool active
});




}
/// @nodoc
class __$PoolCopyWithImpl<$Res>
    implements _$PoolCopyWith<$Res> {
  __$PoolCopyWithImpl(this._self, this._then);

  final _Pool _self;
  final $Res Function(_Pool) _then;

/// Create a copy of Pool
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? createdAt = null,Object? updatedAt = null,Object? description = null,Object? postIds = null,Object? postCount = null,Object? active = null,}) {
  return _then(_Pool(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,postIds: null == postIds ? _self._postIds : postIds // ignore: cast_nullable_to_non_nullable
as List<int>,postCount: null == postCount ? _self.postCount : postCount // ignore: cast_nullable_to_non_nullable
as int,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
