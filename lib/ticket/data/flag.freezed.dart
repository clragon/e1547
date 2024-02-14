// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'flag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PostFlag _$PostFlagFromJson(Map<String, dynamic> json) {
  return _PostFlag.fromJson(json);
}

/// @nodoc
mixin _$PostFlag {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get postId => throw _privateConstructorUsedError;
  String get reason => throw _privateConstructorUsedError;
  int get creatorId => throw _privateConstructorUsedError;
  bool get isResolved => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  bool get isDeletion => throw _privateConstructorUsedError;
  PostFlagType get type => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PostFlagCopyWith<PostFlag> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostFlagCopyWith<$Res> {
  factory $PostFlagCopyWith(PostFlag value, $Res Function(PostFlag) then) =
      _$PostFlagCopyWithImpl<$Res, PostFlag>;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      int postId,
      String reason,
      int creatorId,
      bool isResolved,
      DateTime updatedAt,
      bool isDeletion,
      PostFlagType type});
}

/// @nodoc
class _$PostFlagCopyWithImpl<$Res, $Val extends PostFlag>
    implements $PostFlagCopyWith<$Res> {
  _$PostFlagCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? postId = null,
    Object? reason = null,
    Object? creatorId = null,
    Object? isResolved = null,
    Object? updatedAt = null,
    Object? isDeletion = null,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      postId: null == postId
          ? _value.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as int,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as int,
      isResolved: null == isResolved
          ? _value.isResolved
          : isResolved // ignore: cast_nullable_to_non_nullable
              as bool,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isDeletion: null == isDeletion
          ? _value.isDeletion
          : isDeletion // ignore: cast_nullable_to_non_nullable
              as bool,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PostFlagType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PostFlagImplCopyWith<$Res>
    implements $PostFlagCopyWith<$Res> {
  factory _$$PostFlagImplCopyWith(
          _$PostFlagImpl value, $Res Function(_$PostFlagImpl) then) =
      __$$PostFlagImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      int postId,
      String reason,
      int creatorId,
      bool isResolved,
      DateTime updatedAt,
      bool isDeletion,
      PostFlagType type});
}

/// @nodoc
class __$$PostFlagImplCopyWithImpl<$Res>
    extends _$PostFlagCopyWithImpl<$Res, _$PostFlagImpl>
    implements _$$PostFlagImplCopyWith<$Res> {
  __$$PostFlagImplCopyWithImpl(
      _$PostFlagImpl _value, $Res Function(_$PostFlagImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? postId = null,
    Object? reason = null,
    Object? creatorId = null,
    Object? isResolved = null,
    Object? updatedAt = null,
    Object? isDeletion = null,
    Object? type = null,
  }) {
    return _then(_$PostFlagImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      postId: null == postId
          ? _value.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as int,
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as int,
      isResolved: null == isResolved
          ? _value.isResolved
          : isResolved // ignore: cast_nullable_to_non_nullable
              as bool,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isDeletion: null == isDeletion
          ? _value.isDeletion
          : isDeletion // ignore: cast_nullable_to_non_nullable
              as bool,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as PostFlagType,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PostFlagImpl implements _PostFlag {
  const _$PostFlagImpl(
      {required this.id,
      required this.createdAt,
      required this.postId,
      required this.reason,
      required this.creatorId,
      required this.isResolved,
      required this.updatedAt,
      required this.isDeletion,
      required this.type});

  factory _$PostFlagImpl.fromJson(Map<String, dynamic> json) =>
      _$$PostFlagImplFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final int postId;
  @override
  final String reason;
  @override
  final int creatorId;
  @override
  final bool isResolved;
  @override
  final DateTime updatedAt;
  @override
  final bool isDeletion;
  @override
  final PostFlagType type;

  @override
  String toString() {
    return 'PostFlag(id: $id, createdAt: $createdAt, postId: $postId, reason: $reason, creatorId: $creatorId, isResolved: $isResolved, updatedAt: $updatedAt, isDeletion: $isDeletion, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostFlagImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.isResolved, isResolved) ||
                other.isResolved == isResolved) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isDeletion, isDeletion) ||
                other.isDeletion == isDeletion) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, createdAt, postId, reason,
      creatorId, isResolved, updatedAt, isDeletion, type);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PostFlagImplCopyWith<_$PostFlagImpl> get copyWith =>
      __$$PostFlagImplCopyWithImpl<_$PostFlagImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PostFlagImplToJson(
      this,
    );
  }
}

abstract class _PostFlag implements PostFlag {
  const factory _PostFlag(
      {required final int id,
      required final DateTime createdAt,
      required final int postId,
      required final String reason,
      required final int creatorId,
      required final bool isResolved,
      required final DateTime updatedAt,
      required final bool isDeletion,
      required final PostFlagType type}) = _$PostFlagImpl;

  factory _PostFlag.fromJson(Map<String, dynamic> json) =
      _$PostFlagImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  int get postId;
  @override
  String get reason;
  @override
  int get creatorId;
  @override
  bool get isResolved;
  @override
  DateTime get updatedAt;
  @override
  bool get isDeletion;
  @override
  PostFlagType get type;
  @override
  @JsonKey(ignore: true)
  _$$PostFlagImplCopyWith<_$PostFlagImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
