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
  int? get warningType => throw _privateConstructorUsedError;
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
      _$CommentCopyWithImpl<$Res>;
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
      int? warningType,
      int? warningUserId,
      String creatorName,
      String updaterName,
      @JsonKey(ignore: true) VoteStatus voteStatus});
}

/// @nodoc
class _$CommentCopyWithImpl<$Res> implements $CommentCopyWith<$Res> {
  _$CommentCopyWithImpl(this._value, this._then);

  final Comment _value;
  // ignore: unused_field
  final $Res Function(Comment) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? createdAt = freezed,
    Object? postId = freezed,
    Object? creatorId = freezed,
    Object? body = freezed,
    Object? score = freezed,
    Object? updatedAt = freezed,
    Object? updaterId = freezed,
    Object? doNotBumpPost = freezed,
    Object? isHidden = freezed,
    Object? isSticky = freezed,
    Object? warningType = freezed,
    Object? warningUserId = freezed,
    Object? creatorName = freezed,
    Object? updaterName = freezed,
    Object? voteStatus = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: createdAt == freezed
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      postId: postId == freezed
          ? _value.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as int,
      creatorId: creatorId == freezed
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as int,
      body: body == freezed
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      score: score == freezed
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: updatedAt == freezed
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updaterId: updaterId == freezed
          ? _value.updaterId
          : updaterId // ignore: cast_nullable_to_non_nullable
              as int,
      doNotBumpPost: doNotBumpPost == freezed
          ? _value.doNotBumpPost
          : doNotBumpPost // ignore: cast_nullable_to_non_nullable
              as bool,
      isHidden: isHidden == freezed
          ? _value.isHidden
          : isHidden // ignore: cast_nullable_to_non_nullable
              as bool,
      isSticky: isSticky == freezed
          ? _value.isSticky
          : isSticky // ignore: cast_nullable_to_non_nullable
              as bool,
      warningType: warningType == freezed
          ? _value.warningType
          : warningType // ignore: cast_nullable_to_non_nullable
              as int?,
      warningUserId: warningUserId == freezed
          ? _value.warningUserId
          : warningUserId // ignore: cast_nullable_to_non_nullable
              as int?,
      creatorName: creatorName == freezed
          ? _value.creatorName
          : creatorName // ignore: cast_nullable_to_non_nullable
              as String,
      updaterName: updaterName == freezed
          ? _value.updaterName
          : updaterName // ignore: cast_nullable_to_non_nullable
              as String,
      voteStatus: voteStatus == freezed
          ? _value.voteStatus
          : voteStatus // ignore: cast_nullable_to_non_nullable
              as VoteStatus,
    ));
  }
}

/// @nodoc
abstract class _$$_CommentCopyWith<$Res> implements $CommentCopyWith<$Res> {
  factory _$$_CommentCopyWith(
          _$_Comment value, $Res Function(_$_Comment) then) =
      __$$_CommentCopyWithImpl<$Res>;
  @override
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
      int? warningType,
      int? warningUserId,
      String creatorName,
      String updaterName,
      @JsonKey(ignore: true) VoteStatus voteStatus});
}

/// @nodoc
class __$$_CommentCopyWithImpl<$Res> extends _$CommentCopyWithImpl<$Res>
    implements _$$_CommentCopyWith<$Res> {
  __$$_CommentCopyWithImpl(_$_Comment _value, $Res Function(_$_Comment) _then)
      : super(_value, (v) => _then(v as _$_Comment));

  @override
  _$_Comment get _value => super._value as _$_Comment;

  @override
  $Res call({
    Object? id = freezed,
    Object? createdAt = freezed,
    Object? postId = freezed,
    Object? creatorId = freezed,
    Object? body = freezed,
    Object? score = freezed,
    Object? updatedAt = freezed,
    Object? updaterId = freezed,
    Object? doNotBumpPost = freezed,
    Object? isHidden = freezed,
    Object? isSticky = freezed,
    Object? warningType = freezed,
    Object? warningUserId = freezed,
    Object? creatorName = freezed,
    Object? updaterName = freezed,
    Object? voteStatus = freezed,
  }) {
    return _then(_$_Comment(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: createdAt == freezed
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      postId: postId == freezed
          ? _value.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as int,
      creatorId: creatorId == freezed
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as int,
      body: body == freezed
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      score: score == freezed
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: updatedAt == freezed
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updaterId: updaterId == freezed
          ? _value.updaterId
          : updaterId // ignore: cast_nullable_to_non_nullable
              as int,
      doNotBumpPost: doNotBumpPost == freezed
          ? _value.doNotBumpPost
          : doNotBumpPost // ignore: cast_nullable_to_non_nullable
              as bool,
      isHidden: isHidden == freezed
          ? _value.isHidden
          : isHidden // ignore: cast_nullable_to_non_nullable
              as bool,
      isSticky: isSticky == freezed
          ? _value.isSticky
          : isSticky // ignore: cast_nullable_to_non_nullable
              as bool,
      warningType: warningType == freezed
          ? _value.warningType
          : warningType // ignore: cast_nullable_to_non_nullable
              as int?,
      warningUserId: warningUserId == freezed
          ? _value.warningUserId
          : warningUserId // ignore: cast_nullable_to_non_nullable
              as int?,
      creatorName: creatorName == freezed
          ? _value.creatorName
          : creatorName // ignore: cast_nullable_to_non_nullable
              as String,
      updaterName: updaterName == freezed
          ? _value.updaterName
          : updaterName // ignore: cast_nullable_to_non_nullable
              as String,
      voteStatus: voteStatus == freezed
          ? _value.voteStatus
          : voteStatus // ignore: cast_nullable_to_non_nullable
              as VoteStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Comment with DiagnosticableTreeMixin implements _Comment {
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
  final int? warningType;
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
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Comment(id: $id, createdAt: $createdAt, postId: $postId, creatorId: $creatorId, body: $body, score: $score, updatedAt: $updatedAt, updaterId: $updaterId, doNotBumpPost: $doNotBumpPost, isHidden: $isHidden, isSticky: $isSticky, warningType: $warningType, warningUserId: $warningUserId, creatorName: $creatorName, updaterName: $updaterName, voteStatus: $voteStatus)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Comment'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('postId', postId))
      ..add(DiagnosticsProperty('creatorId', creatorId))
      ..add(DiagnosticsProperty('body', body))
      ..add(DiagnosticsProperty('score', score))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('updaterId', updaterId))
      ..add(DiagnosticsProperty('doNotBumpPost', doNotBumpPost))
      ..add(DiagnosticsProperty('isHidden', isHidden))
      ..add(DiagnosticsProperty('isSticky', isSticky))
      ..add(DiagnosticsProperty('warningType', warningType))
      ..add(DiagnosticsProperty('warningUserId', warningUserId))
      ..add(DiagnosticsProperty('creatorName', creatorName))
      ..add(DiagnosticsProperty('updaterName', updaterName))
      ..add(DiagnosticsProperty('voteStatus', voteStatus));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Comment &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.createdAt, createdAt) &&
            const DeepCollectionEquality().equals(other.postId, postId) &&
            const DeepCollectionEquality().equals(other.creatorId, creatorId) &&
            const DeepCollectionEquality().equals(other.body, body) &&
            const DeepCollectionEquality().equals(other.score, score) &&
            const DeepCollectionEquality().equals(other.updatedAt, updatedAt) &&
            const DeepCollectionEquality().equals(other.updaterId, updaterId) &&
            const DeepCollectionEquality()
                .equals(other.doNotBumpPost, doNotBumpPost) &&
            const DeepCollectionEquality().equals(other.isHidden, isHidden) &&
            const DeepCollectionEquality().equals(other.isSticky, isSticky) &&
            const DeepCollectionEquality()
                .equals(other.warningType, warningType) &&
            const DeepCollectionEquality()
                .equals(other.warningUserId, warningUserId) &&
            const DeepCollectionEquality()
                .equals(other.creatorName, creatorName) &&
            const DeepCollectionEquality()
                .equals(other.updaterName, updaterName) &&
            const DeepCollectionEquality()
                .equals(other.voteStatus, voteStatus));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(createdAt),
      const DeepCollectionEquality().hash(postId),
      const DeepCollectionEquality().hash(creatorId),
      const DeepCollectionEquality().hash(body),
      const DeepCollectionEquality().hash(score),
      const DeepCollectionEquality().hash(updatedAt),
      const DeepCollectionEquality().hash(updaterId),
      const DeepCollectionEquality().hash(doNotBumpPost),
      const DeepCollectionEquality().hash(isHidden),
      const DeepCollectionEquality().hash(isSticky),
      const DeepCollectionEquality().hash(warningType),
      const DeepCollectionEquality().hash(warningUserId),
      const DeepCollectionEquality().hash(creatorName),
      const DeepCollectionEquality().hash(updaterName),
      const DeepCollectionEquality().hash(voteStatus));

  @JsonKey(ignore: true)
  @override
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
      required final int? warningType,
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
  int? get warningType;
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
