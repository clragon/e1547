// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Comment _$CommentFromJson(Map<String, dynamic> json) {
  return _Comment.fromJson(json);
}

/// @nodoc
mixin _$Comment {
  int get id => throw _privateConstructorUsedError;
  int get postId => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  int get creatorId => throw _privateConstructorUsedError;
  String? get creatorName => throw _privateConstructorUsedError;
  VoteInfo? get vote => throw _privateConstructorUsedError;
  CommentWarning? get warning => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommentCopyWith<Comment> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentCopyWith<$Res> {
  factory $CommentCopyWith(Comment value, $Res Function(Comment) then) =
      _$CommentCopyWithImpl<$Res, Comment>;
  @useResult
  $Res call(
      {int id,
      int postId,
      String body,
      DateTime createdAt,
      DateTime updatedAt,
      int creatorId,
      String? creatorName,
      VoteInfo? vote,
      CommentWarning? warning});

  $CommentWarningCopyWith<$Res>? get warning;
}

/// @nodoc
class _$CommentCopyWithImpl<$Res, $Val extends Comment>
    implements $CommentCopyWith<$Res> {
  _$CommentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? postId = null,
    Object? body = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? creatorId = null,
    Object? creatorName = freezed,
    Object? vote = freezed,
    Object? warning = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      postId: null == postId
          ? _value.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as int,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as int,
      creatorName: freezed == creatorName
          ? _value.creatorName
          : creatorName // ignore: cast_nullable_to_non_nullable
              as String?,
      vote: freezed == vote
          ? _value.vote
          : vote // ignore: cast_nullable_to_non_nullable
              as VoteInfo?,
      warning: freezed == warning
          ? _value.warning
          : warning // ignore: cast_nullable_to_non_nullable
              as CommentWarning?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CommentWarningCopyWith<$Res>? get warning {
    if (_value.warning == null) {
      return null;
    }

    return $CommentWarningCopyWith<$Res>(_value.warning!, (value) {
      return _then(_value.copyWith(warning: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CommentImplCopyWith<$Res> implements $CommentCopyWith<$Res> {
  factory _$$CommentImplCopyWith(
          _$CommentImpl value, $Res Function(_$CommentImpl) then) =
      __$$CommentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int postId,
      String body,
      DateTime createdAt,
      DateTime updatedAt,
      int creatorId,
      String? creatorName,
      VoteInfo? vote,
      CommentWarning? warning});

  @override
  $CommentWarningCopyWith<$Res>? get warning;
}

/// @nodoc
class __$$CommentImplCopyWithImpl<$Res>
    extends _$CommentCopyWithImpl<$Res, _$CommentImpl>
    implements _$$CommentImplCopyWith<$Res> {
  __$$CommentImplCopyWithImpl(
      _$CommentImpl _value, $Res Function(_$CommentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? postId = null,
    Object? body = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? creatorId = null,
    Object? creatorName = freezed,
    Object? vote = freezed,
    Object? warning = freezed,
  }) {
    return _then(_$CommentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      postId: null == postId
          ? _value.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as int,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as int,
      creatorName: freezed == creatorName
          ? _value.creatorName
          : creatorName // ignore: cast_nullable_to_non_nullable
              as String?,
      vote: freezed == vote
          ? _value.vote
          : vote // ignore: cast_nullable_to_non_nullable
              as VoteInfo?,
      warning: freezed == warning
          ? _value.warning
          : warning // ignore: cast_nullable_to_non_nullable
              as CommentWarning?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommentImpl implements _Comment {
  const _$CommentImpl(
      {required this.id,
      required this.postId,
      required this.body,
      required this.createdAt,
      required this.updatedAt,
      required this.creatorId,
      required this.creatorName,
      required this.vote,
      required this.warning});

  factory _$CommentImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommentImplFromJson(json);

  @override
  final int id;
  @override
  final int postId;
  @override
  final String body;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final int creatorId;
  @override
  final String? creatorName;
  @override
  final VoteInfo? vote;
  @override
  final CommentWarning? warning;

  @override
  String toString() {
    return 'Comment(id: $id, postId: $postId, body: $body, createdAt: $createdAt, updatedAt: $updatedAt, creatorId: $creatorId, creatorName: $creatorName, vote: $vote, warning: $warning)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.creatorName, creatorName) ||
                other.creatorName == creatorName) &&
            (identical(other.vote, vote) || other.vote == vote) &&
            (identical(other.warning, warning) || other.warning == warning));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, postId, body, createdAt,
      updatedAt, creatorId, creatorName, vote, warning);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentImplCopyWith<_$CommentImpl> get copyWith =>
      __$$CommentImplCopyWithImpl<_$CommentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommentImplToJson(
      this,
    );
  }
}

abstract class _Comment implements Comment {
  const factory _Comment(
      {required final int id,
      required final int postId,
      required final String body,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final int creatorId,
      required final String? creatorName,
      required final VoteInfo? vote,
      required final CommentWarning? warning}) = _$CommentImpl;

  factory _Comment.fromJson(Map<String, dynamic> json) = _$CommentImpl.fromJson;

  @override
  int get id;
  @override
  int get postId;
  @override
  String get body;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  int get creatorId;
  @override
  String? get creatorName;
  @override
  VoteInfo? get vote;
  @override
  CommentWarning? get warning;
  @override
  @JsonKey(ignore: true)
  _$$CommentImplCopyWith<_$CommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CommentWarning _$CommentWarningFromJson(Map<String, dynamic> json) {
  return _CommentWarning.fromJson(json);
}

/// @nodoc
mixin _$CommentWarning {
  WarningType? get type => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CommentWarningCopyWith<CommentWarning> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentWarningCopyWith<$Res> {
  factory $CommentWarningCopyWith(
          CommentWarning value, $Res Function(CommentWarning) then) =
      _$CommentWarningCopyWithImpl<$Res, CommentWarning>;
  @useResult
  $Res call({WarningType? type});
}

/// @nodoc
class _$CommentWarningCopyWithImpl<$Res, $Val extends CommentWarning>
    implements $CommentWarningCopyWith<$Res> {
  _$CommentWarningCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = freezed,
  }) {
    return _then(_value.copyWith(
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as WarningType?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommentWarningImplCopyWith<$Res>
    implements $CommentWarningCopyWith<$Res> {
  factory _$$CommentWarningImplCopyWith(_$CommentWarningImpl value,
          $Res Function(_$CommentWarningImpl) then) =
      __$$CommentWarningImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({WarningType? type});
}

/// @nodoc
class __$$CommentWarningImplCopyWithImpl<$Res>
    extends _$CommentWarningCopyWithImpl<$Res, _$CommentWarningImpl>
    implements _$$CommentWarningImplCopyWith<$Res> {
  __$$CommentWarningImplCopyWithImpl(
      _$CommentWarningImpl _value, $Res Function(_$CommentWarningImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = freezed,
  }) {
    return _then(_$CommentWarningImpl(
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as WarningType?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommentWarningImpl implements _CommentWarning {
  const _$CommentWarningImpl({required this.type});

  factory _$CommentWarningImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommentWarningImplFromJson(json);

  @override
  final WarningType? type;

  @override
  String toString() {
    return 'CommentWarning(type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentWarningImpl &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, type);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentWarningImplCopyWith<_$CommentWarningImpl> get copyWith =>
      __$$CommentWarningImplCopyWithImpl<_$CommentWarningImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommentWarningImplToJson(
      this,
    );
  }
}

abstract class _CommentWarning implements CommentWarning {
  const factory _CommentWarning({required final WarningType? type}) =
      _$CommentWarningImpl;

  factory _CommentWarning.fromJson(Map<String, dynamic> json) =
      _$CommentWarningImpl.fromJson;

  @override
  WarningType? get type;
  @override
  @JsonKey(ignore: true)
  _$$CommentWarningImplCopyWith<_$CommentWarningImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
