// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reply.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Reply _$ReplyFromJson(Map<String, dynamic> json) {
  return _Reply.fromJson(json);
}

/// @nodoc
mixin _$Reply {
  int get id => throw _privateConstructorUsedError;
  int get creatorId => throw _privateConstructorUsedError;
  String get creator => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int? get updaterId => throw _privateConstructorUsedError;
  String? get updater => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  int get topicId => throw _privateConstructorUsedError;
  WarningType? get warning => throw _privateConstructorUsedError;
  bool get hidden => throw _privateConstructorUsedError;

  /// Serializes this Reply to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Reply
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReplyCopyWith<Reply> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReplyCopyWith<$Res> {
  factory $ReplyCopyWith(Reply value, $Res Function(Reply) then) =
      _$ReplyCopyWithImpl<$Res, Reply>;
  @useResult
  $Res call({
    int id,
    int creatorId,
    String creator,
    DateTime createdAt,
    int? updaterId,
    String? updater,
    DateTime updatedAt,
    String body,
    int topicId,
    WarningType? warning,
    bool hidden,
  });
}

/// @nodoc
class _$ReplyCopyWithImpl<$Res, $Val extends Reply>
    implements $ReplyCopyWith<$Res> {
  _$ReplyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Reply
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? creatorId = null,
    Object? creator = null,
    Object? createdAt = null,
    Object? updaterId = freezed,
    Object? updater = freezed,
    Object? updatedAt = null,
    Object? body = null,
    Object? topicId = null,
    Object? warning = freezed,
    Object? hidden = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            creatorId: null == creatorId
                ? _value.creatorId
                : creatorId // ignore: cast_nullable_to_non_nullable
                      as int,
            creator: null == creator
                ? _value.creator
                : creator // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updaterId: freezed == updaterId
                ? _value.updaterId
                : updaterId // ignore: cast_nullable_to_non_nullable
                      as int?,
            updater: freezed == updater
                ? _value.updater
                : updater // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            topicId: null == topicId
                ? _value.topicId
                : topicId // ignore: cast_nullable_to_non_nullable
                      as int,
            warning: freezed == warning
                ? _value.warning
                : warning // ignore: cast_nullable_to_non_nullable
                      as WarningType?,
            hidden: null == hidden
                ? _value.hidden
                : hidden // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReplyImplCopyWith<$Res> implements $ReplyCopyWith<$Res> {
  factory _$$ReplyImplCopyWith(
    _$ReplyImpl value,
    $Res Function(_$ReplyImpl) then,
  ) = __$$ReplyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int creatorId,
    String creator,
    DateTime createdAt,
    int? updaterId,
    String? updater,
    DateTime updatedAt,
    String body,
    int topicId,
    WarningType? warning,
    bool hidden,
  });
}

/// @nodoc
class __$$ReplyImplCopyWithImpl<$Res>
    extends _$ReplyCopyWithImpl<$Res, _$ReplyImpl>
    implements _$$ReplyImplCopyWith<$Res> {
  __$$ReplyImplCopyWithImpl(
    _$ReplyImpl _value,
    $Res Function(_$ReplyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Reply
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? creatorId = null,
    Object? creator = null,
    Object? createdAt = null,
    Object? updaterId = freezed,
    Object? updater = freezed,
    Object? updatedAt = null,
    Object? body = null,
    Object? topicId = null,
    Object? warning = freezed,
    Object? hidden = null,
  }) {
    return _then(
      _$ReplyImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        creatorId: null == creatorId
            ? _value.creatorId
            : creatorId // ignore: cast_nullable_to_non_nullable
                  as int,
        creator: null == creator
            ? _value.creator
            : creator // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updaterId: freezed == updaterId
            ? _value.updaterId
            : updaterId // ignore: cast_nullable_to_non_nullable
                  as int?,
        updater: freezed == updater
            ? _value.updater
            : updater // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        topicId: null == topicId
            ? _value.topicId
            : topicId // ignore: cast_nullable_to_non_nullable
                  as int,
        warning: freezed == warning
            ? _value.warning
            : warning // ignore: cast_nullable_to_non_nullable
                  as WarningType?,
        hidden: null == hidden
            ? _value.hidden
            : hidden // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReplyImpl implements _Reply {
  const _$ReplyImpl({
    required this.id,
    required this.creatorId,
    required this.creator,
    required this.createdAt,
    required this.updaterId,
    required this.updater,
    required this.updatedAt,
    required this.body,
    required this.topicId,
    required this.warning,
    required this.hidden,
  });

  factory _$ReplyImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReplyImplFromJson(json);

  @override
  final int id;
  @override
  final int creatorId;
  @override
  final String creator;
  @override
  final DateTime createdAt;
  @override
  final int? updaterId;
  @override
  final String? updater;
  @override
  final DateTime updatedAt;
  @override
  final String body;
  @override
  final int topicId;
  @override
  final WarningType? warning;
  @override
  final bool hidden;

  @override
  String toString() {
    return 'Reply(id: $id, creatorId: $creatorId, creator: $creator, createdAt: $createdAt, updaterId: $updaterId, updater: $updater, updatedAt: $updatedAt, body: $body, topicId: $topicId, warning: $warning, hidden: $hidden)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReplyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.creator, creator) || other.creator == creator) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updaterId, updaterId) ||
                other.updaterId == updaterId) &&
            (identical(other.updater, updater) || other.updater == updater) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.topicId, topicId) || other.topicId == topicId) &&
            (identical(other.warning, warning) || other.warning == warning) &&
            (identical(other.hidden, hidden) || other.hidden == hidden));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    creatorId,
    creator,
    createdAt,
    updaterId,
    updater,
    updatedAt,
    body,
    topicId,
    warning,
    hidden,
  );

  /// Create a copy of Reply
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReplyImplCopyWith<_$ReplyImpl> get copyWith =>
      __$$ReplyImplCopyWithImpl<_$ReplyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReplyImplToJson(this);
  }
}

abstract class _Reply implements Reply {
  const factory _Reply({
    required final int id,
    required final int creatorId,
    required final String creator,
    required final DateTime createdAt,
    required final int? updaterId,
    required final String? updater,
    required final DateTime updatedAt,
    required final String body,
    required final int topicId,
    required final WarningType? warning,
    required final bool hidden,
  }) = _$ReplyImpl;

  factory _Reply.fromJson(Map<String, dynamic> json) = _$ReplyImpl.fromJson;

  @override
  int get id;
  @override
  int get creatorId;
  @override
  String get creator;
  @override
  DateTime get createdAt;
  @override
  int? get updaterId;
  @override
  String? get updater;
  @override
  DateTime get updatedAt;
  @override
  String get body;
  @override
  int get topicId;
  @override
  WarningType? get warning;
  @override
  bool get hidden;

  /// Create a copy of Reply
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReplyImplCopyWith<_$ReplyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
