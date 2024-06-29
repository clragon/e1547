// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pool.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Pool _$PoolFromJson(Map<String, dynamic> json) {
  return _Pool.fromJson(json);
}

/// @nodoc
mixin _$Pool {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<int> get postIds => throw _privateConstructorUsedError;
  int get postCount => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PoolCopyWith<Pool> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PoolCopyWith<$Res> {
  factory $PoolCopyWith(Pool value, $Res Function(Pool) then) =
      _$PoolCopyWithImpl<$Res, Pool>;
  @useResult
  $Res call(
      {int id,
      String name,
      DateTime createdAt,
      DateTime updatedAt,
      String description,
      List<int> postIds,
      int postCount,
      bool active});
}

/// @nodoc
class _$PoolCopyWithImpl<$Res, $Val extends Pool>
    implements $PoolCopyWith<$Res> {
  _$PoolCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? description = null,
    Object? postIds = null,
    Object? postCount = null,
    Object? active = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      postIds: null == postIds
          ? _value.postIds
          : postIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
      postCount: null == postCount
          ? _value.postCount
          : postCount // ignore: cast_nullable_to_non_nullable
              as int,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PoolImplCopyWith<$Res> implements $PoolCopyWith<$Res> {
  factory _$$PoolImplCopyWith(
          _$PoolImpl value, $Res Function(_$PoolImpl) then) =
      __$$PoolImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      DateTime createdAt,
      DateTime updatedAt,
      String description,
      List<int> postIds,
      int postCount,
      bool active});
}

/// @nodoc
class __$$PoolImplCopyWithImpl<$Res>
    extends _$PoolCopyWithImpl<$Res, _$PoolImpl>
    implements _$$PoolImplCopyWith<$Res> {
  __$$PoolImplCopyWithImpl(_$PoolImpl _value, $Res Function(_$PoolImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? description = null,
    Object? postIds = null,
    Object? postCount = null,
    Object? active = null,
  }) {
    return _then(_$PoolImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      postIds: null == postIds
          ? _value._postIds
          : postIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
      postCount: null == postCount
          ? _value.postCount
          : postCount // ignore: cast_nullable_to_non_nullable
              as int,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PoolImpl implements _Pool {
  const _$PoolImpl(
      {required this.id,
      required this.name,
      required this.createdAt,
      required this.updatedAt,
      required this.description,
      required final List<int> postIds,
      required this.postCount,
      required this.active})
      : _postIds = postIds;

  factory _$PoolImpl.fromJson(Map<String, dynamic> json) =>
      _$$PoolImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String description;
  final List<int> _postIds;
  @override
  List<int> get postIds {
    if (_postIds is EqualUnmodifiableListView) return _postIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_postIds);
  }

  @override
  final int postCount;
  @override
  final bool active;

  @override
  String toString() {
    return 'Pool(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, postIds: $postIds, postCount: $postCount, active: $active)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PoolImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._postIds, _postIds) &&
            (identical(other.postCount, postCount) ||
                other.postCount == postCount) &&
            (identical(other.active, active) || other.active == active));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      createdAt,
      updatedAt,
      description,
      const DeepCollectionEquality().hash(_postIds),
      postCount,
      active);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PoolImplCopyWith<_$PoolImpl> get copyWith =>
      __$$PoolImplCopyWithImpl<_$PoolImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PoolImplToJson(
      this,
    );
  }
}

abstract class _Pool implements Pool {
  const factory _Pool(
      {required final int id,
      required final String name,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final String description,
      required final List<int> postIds,
      required final int postCount,
      required final bool active}) = _$PoolImpl;

  factory _Pool.fromJson(Map<String, dynamic> json) = _$PoolImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String get description;
  @override
  List<int> get postIds;
  @override
  int get postCount;
  @override
  bool get active;
  @override
  @JsonKey(ignore: true)
  _$$PoolImplCopyWith<_$PoolImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
