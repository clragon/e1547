// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'comment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Comment _$CommentFromJson(Map<String, dynamic> json) {
  return _Comment.fromJson(json);
}

/// @nodoc
mixin _$Comment {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get postId => throw _privateConstructorUsedError;
  int get creatorId => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  int get updaterId => throw _privateConstructorUsedError;
  bool get doNotBumpPost => throw _privateConstructorUsedError;
  bool get isHidden => throw _privateConstructorUsedError;
  bool get isSticky => throw _privateConstructorUsedError;

  WarningType? get warningType => throw _privateConstructorUsedError;

  int? get warningUserId => throw _privateConstructorUsedError;
  String get creatorName => throw _privateConstructorUsedError;
  String get updaterName => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  VoteStatus get voteStatus => throw _privateConstructorUsedError;

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
      DateTime createdAt,
      int postId,
      int creatorId,
      String body,
      int score,
      DateTime updatedAt,
      int updaterId,
      bool doNotBumpPost,
      bool isHidden,
      bool isSticky,
      WarningType? warningType,
      int? warningUserId,
      String creatorName,
      String updaterName,
      @JsonKey(ignore: true) VoteStatus voteStatus});
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
    Object? createdAt = null,
    Object? postId = null,
    Object? creatorId = null,
    Object? body = null,
    Object? score = null,
    Object? updatedAt = null,
    Object? updaterId = null,
    Object? doNotBumpPost = null,
    Object? isHidden = null,
    Object? isSticky = null,
    Object? warningType = freezed,
    Object? warningUserId = freezed,
    Object? creatorName = null,
    Object? updaterName = null,
    Object? voteStatus = null,
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
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as int,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updaterId: null == updaterId
          ? _value.updaterId
          : updaterId // ignore: cast_nullable_to_non_nullable
              as int,
      doNotBumpPost: null == doNotBumpPost
          ? _value.doNotBumpPost
          : doNotBumpPost // ignore: cast_nullable_to_non_nullable
              as bool,
      isHidden: null == isHidden
          ? _value.isHidden
          : isHidden // ignore: cast_nullable_to_non_nullable
              as bool,
      isSticky: null == isSticky
          ? _value.isSticky
          : isSticky // ignore: cast_nullable_to_non_nullable
              as bool,
      warningType: freezed == warningType
          ? _value.warningType
          : warningType // ignore: cast_nullable_to_non_nullable
              as WarningType?,
      warningUserId: freezed == warningUserId
          ? _value.warningUserId
          : warningUserId // ignore: cast_nullable_to_non_nullable
              as int?,
      creatorName: null == creatorName
          ? _value.creatorName
          : creatorName // ignore: cast_nullable_to_non_nullable
              as String,
      updaterName: null == updaterName
          ? _value.updaterName
          : updaterName // ignore: cast_nullable_to_non_nullable
              as String,
      voteStatus: null == voteStatus
          ? _value.voteStatus
          : voteStatus // ignore: cast_nullable_to_non_nullable
              as VoteStatus,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_CommentCopyWith<$Res> implements $CommentCopyWith<$Res> {
  factory _$$_CommentCopyWith(
          _$_Comment value, $Res Function(_$_Comment) then) =
      __$$_CommentCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      int postId,
      int creatorId,
      String body,
      int score,
      DateTime updatedAt,
      int updaterId,
      bool doNotBumpPost,
      bool isHidden,
      bool isSticky,
      WarningType? warningType,
      int? warningUserId,
      String creatorName,
      String updaterName,
      @JsonKey(ignore: true) VoteStatus voteStatus});
}

/// @nodoc
class __$$_CommentCopyWithImpl<$Res>
    extends _$CommentCopyWithImpl<$Res, _$_Comment>
    implements _$$_CommentCopyWith<$Res> {
  __$$_CommentCopyWithImpl(_$_Comment _value, $Res Function(_$_Comment) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? postId = null,
    Object? creatorId = null,
    Object? body = null,
    Object? score = null,
    Object? updatedAt = null,
    Object? updaterId = null,
    Object? doNotBumpPost = null,
    Object? isHidden = null,
    Object? isSticky = null,
    Object? warningType = freezed,
    Object? warningUserId = freezed,
    Object? creatorName = null,
    Object? updaterName = null,
    Object? voteStatus = null,
  }) {
    return _then(_$_Comment(
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
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as int,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updaterId: null == updaterId
          ? _value.updaterId
          : updaterId // ignore: cast_nullable_to_non_nullable
              as int,
      doNotBumpPost: null == doNotBumpPost
          ? _value.doNotBumpPost
          : doNotBumpPost // ignore: cast_nullable_to_non_nullable
              as bool,
      isHidden: null == isHidden
          ? _value.isHidden
          : isHidden // ignore: cast_nullable_to_non_nullable
              as bool,
      isSticky: null == isSticky
          ? _value.isSticky
          : isSticky // ignore: cast_nullable_to_non_nullable
              as bool,
      warningType: freezed == warningType
          ? _value.warningType
          : warningType // ignore: cast_nullable_to_non_nullable
              as WarningType?,
      warningUserId: freezed == warningUserId
          ? _value.warningUserId
          : warningUserId // ignore: cast_nullable_to_non_nullable
              as int?,
      creatorName: null == creatorName
          ? _value.creatorName
          : creatorName // ignore: cast_nullable_to_non_nullable
              as String,
      updaterName: null == updaterName
          ? _value.updaterName
          : updaterName // ignore: cast_nullable_to_non_nullable
              as String,
      voteStatus: null == voteStatus
          ? _value.voteStatus
          : voteStatus // ignore: cast_nullable_to_non_nullable
              as VoteStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Comment implements _Comment {
  const _$_Comment(
      {required this.id,
      required this.createdAt,
      required this.postId,
      required this.creatorId,
      required this.body,
      required this.score,
      required this.updatedAt,
      required this.updaterId,
      required this.doNotBumpPost,
      required this.isHidden,
      required this.isSticky,
      required this.warningType,
      required this.warningUserId,
      required this.creatorName,
      required this.updaterName,
      @JsonKey(ignore: true) this.voteStatus = VoteStatus.unknown});

  factory _$_Comment.fromJson(Map<String, dynamic> json) =>
      _$$_CommentFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final int postId;
  @override
  final int creatorId;
  @override
  final String body;
  @override
  final int score;
  @override
  final DateTime updatedAt;
  @override
  final int updaterId;
  @override
  final bool doNotBumpPost;
  @override
  final bool isHidden;
  @override
  final bool isSticky;
  @override
  final WarningType? warningType;
  @override
  final int? warningUserId;
  @override
  final String creatorName;
  @override
  final String updaterName;
  @override
  @JsonKey(ignore: true)
  final VoteStatus voteStatus;

  @override
  String toString() {
    return 'Comment(id: $id, createdAt: $createdAt, postId: $postId, creatorId: $creatorId, body: $body, score: $score, updatedAt: $updatedAt, updaterId: $updaterId, doNotBumpPost: $doNotBumpPost, isHidden: $isHidden, isSticky: $isSticky, warningType: $warningType, warningUserId: $warningUserId, creatorName: $creatorName, updaterName: $updaterName, voteStatus: $voteStatus)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Comment &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.updaterId, updaterId) ||
                other.updaterId == updaterId) &&
            (identical(other.doNotBumpPost, doNotBumpPost) ||
                other.doNotBumpPost == doNotBumpPost) &&
            (identical(other.isHidden, isHidden) ||
                other.isHidden == isHidden) &&
            (identical(other.isSticky, isSticky) ||
                other.isSticky == isSticky) &&
            (identical(other.warningType, warningType) ||
                other.warningType == warningType) &&
            (identical(other.warningUserId, warningUserId) ||
                other.warningUserId == warningUserId) &&
            (identical(other.creatorName, creatorName) ||
                other.creatorName == creatorName) &&
            (identical(other.updaterName, updaterName) ||
                other.updaterName == updaterName) &&
            (identical(other.voteStatus, voteStatus) ||
                other.voteStatus == voteStatus));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      createdAt,
      postId,
      creatorId,
      body,
      score,
      updatedAt,
      updaterId,
      doNotBumpPost,
      isHidden,
      isSticky,
      warningType,
      warningUserId,
      creatorName,
      updaterName,
      voteStatus);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_CommentCopyWith<_$_Comment> get copyWith =>
      __$$_CommentCopyWithImpl<_$_Comment>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_CommentToJson(
      this,
    );
  }
}

abstract class _Comment implements Comment {
  const factory _Comment(
      {required final int id,
      required final DateTime createdAt,
      required final int postId,
      required final int creatorId,
      required final String body,
      required final int score,
      required final DateTime updatedAt,
      required final int updaterId,
      required final bool doNotBumpPost,
      required final bool isHidden,
      required final bool isSticky,
      required final WarningType? warningType,
      required final int? warningUserId,
      required final String creatorName,
      required final String updaterName,
      @JsonKey(ignore: true) final VoteStatus voteStatus}) = _$_Comment;

  factory _Comment.fromJson(Map<String, dynamic> json) = _$_Comment.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  int get postId;
  @override
  int get creatorId;
  @override
  String get body;
  @override
  int get score;
  @override
  DateTime get updatedAt;
  @override
  int get updaterId;
  @override
  bool get doNotBumpPost;
  @override
  bool get isHidden;

  @override
  bool get isSticky;

  @override
  WarningType? get warningType;

  @override
  int? get warningUserId;
  @override
  String get creatorName;
  @override
  String get updaterName;
  @override
  @JsonKey(ignore: true)
  VoteStatus get voteStatus;
  @override
  @JsonKey(ignore: true)
  _$$_CommentCopyWith<_$_Comment> get copyWith =>
      throw _privateConstructorUsedError;
}
