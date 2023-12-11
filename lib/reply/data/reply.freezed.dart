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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Reply _$ReplyFromJson(Map<String, dynamic> json) {
  return _Reply.fromJson(json);
}

/// @nodoc
mixin _$Reply {
  int get id => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  int get creatorId => throw _privateConstructorUsedError;
  int get topicId => throw _privateConstructorUsedError;
  ReplyWarning? get warning => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReplyCopyWith<Reply> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReplyCopyWith<$Res> {
  factory $ReplyCopyWith(Reply value, $Res Function(Reply) then) =
      _$ReplyCopyWithImpl<$Res, Reply>;
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      String body,
      int creatorId,
      int topicId,
      ReplyWarning? warning});

  $ReplyWarningCopyWith<$Res>? get warning;
}

/// @nodoc
class _$ReplyCopyWithImpl<$Res, $Val extends Reply>
    implements $ReplyCopyWith<$Res> {
  _$ReplyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? body = null,
    Object? creatorId = null,
    Object? topicId = null,
    Object? warning = freezed,
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
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as int,
      topicId: null == topicId
          ? _value.topicId
          : topicId // ignore: cast_nullable_to_non_nullable
              as int,
      warning: freezed == warning
          ? _value.warning
          : warning // ignore: cast_nullable_to_non_nullable
              as ReplyWarning?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ReplyWarningCopyWith<$Res>? get warning {
    if (_value.warning == null) {
      return null;
    }

    return $ReplyWarningCopyWith<$Res>(_value.warning!, (value) {
      return _then(_value.copyWith(warning: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReplyImplCopyWith<$Res> implements $ReplyCopyWith<$Res> {
  factory _$$ReplyImplCopyWith(
          _$ReplyImpl value, $Res Function(_$ReplyImpl) then) =
      __$$ReplyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime createdAt,
      DateTime updatedAt,
      String body,
      int creatorId,
      int topicId,
      ReplyWarning? warning});

  @override
  $ReplyWarningCopyWith<$Res>? get warning;
}

/// @nodoc
class __$$ReplyImplCopyWithImpl<$Res>
    extends _$ReplyCopyWithImpl<$Res, _$ReplyImpl>
    implements _$$ReplyImplCopyWith<$Res> {
  __$$ReplyImplCopyWithImpl(
      _$ReplyImpl _value, $Res Function(_$ReplyImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? body = null,
    Object? creatorId = null,
    Object? topicId = null,
    Object? warning = freezed,
  }) {
    return _then(_$ReplyImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as int,
      topicId: null == topicId
          ? _value.topicId
          : topicId // ignore: cast_nullable_to_non_nullable
              as int,
      warning: freezed == warning
          ? _value.warning
          : warning // ignore: cast_nullable_to_non_nullable
              as ReplyWarning?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReplyImpl implements _Reply {
  const _$ReplyImpl(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.body,
      required this.creatorId,
      required this.topicId,
      required this.warning});

  factory _$ReplyImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReplyImplFromJson(json);

  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String body;
  @override
  final int creatorId;
  @override
  final int topicId;
  @override
  final ReplyWarning? warning;

  @override
  String toString() {
    return 'Reply(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, body: $body, creatorId: $creatorId, topicId: $topicId, warning: $warning)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReplyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.topicId, topicId) || other.topicId == topicId) &&
            (identical(other.warning, warning) || other.warning == warning));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, createdAt, updatedAt, body, creatorId, topicId, warning);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReplyImplCopyWith<_$ReplyImpl> get copyWith =>
      __$$ReplyImplCopyWithImpl<_$ReplyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReplyImplToJson(
      this,
    );
  }
}

abstract class _Reply implements Reply {
  const factory _Reply(
      {required final int id,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final String body,
      required final int creatorId,
      required final int topicId,
      required final ReplyWarning? warning}) = _$ReplyImpl;

  factory _Reply.fromJson(Map<String, dynamic> json) = _$ReplyImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String get body;
  @override
  int get creatorId;
  @override
  int get topicId;
  @override
  ReplyWarning? get warning;
  @override
  @JsonKey(ignore: true)
  _$$ReplyImplCopyWith<_$ReplyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReplyWarning _$ReplyWarningFromJson(Map<String, dynamic> json) {
  return _ReplyWarning.fromJson(json);
}

/// @nodoc
mixin _$ReplyWarning {
  WarningType? get type => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReplyWarningCopyWith<ReplyWarning> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReplyWarningCopyWith<$Res> {
  factory $ReplyWarningCopyWith(
          ReplyWarning value, $Res Function(ReplyWarning) then) =
      _$ReplyWarningCopyWithImpl<$Res, ReplyWarning>;
  @useResult
  $Res call({WarningType? type});
}

/// @nodoc
class _$ReplyWarningCopyWithImpl<$Res, $Val extends ReplyWarning>
    implements $ReplyWarningCopyWith<$Res> {
  _$ReplyWarningCopyWithImpl(this._value, this._then);

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
abstract class _$$ReplyWarningImplCopyWith<$Res>
    implements $ReplyWarningCopyWith<$Res> {
  factory _$$ReplyWarningImplCopyWith(
          _$ReplyWarningImpl value, $Res Function(_$ReplyWarningImpl) then) =
      __$$ReplyWarningImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({WarningType? type});
}

/// @nodoc
class __$$ReplyWarningImplCopyWithImpl<$Res>
    extends _$ReplyWarningCopyWithImpl<$Res, _$ReplyWarningImpl>
    implements _$$ReplyWarningImplCopyWith<$Res> {
  __$$ReplyWarningImplCopyWithImpl(
      _$ReplyWarningImpl _value, $Res Function(_$ReplyWarningImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = freezed,
  }) {
    return _then(_$ReplyWarningImpl(
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as WarningType?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReplyWarningImpl implements _ReplyWarning {
  const _$ReplyWarningImpl({required this.type});

  factory _$ReplyWarningImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReplyWarningImplFromJson(json);

  @override
  final WarningType? type;

  @override
  String toString() {
    return 'ReplyWarning(type: $type)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReplyWarningImpl &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, type);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReplyWarningImplCopyWith<_$ReplyWarningImpl> get copyWith =>
      __$$ReplyWarningImplCopyWithImpl<_$ReplyWarningImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReplyWarningImplToJson(
      this,
    );
  }
}

abstract class _ReplyWarning implements ReplyWarning {
  const factory _ReplyWarning({required final WarningType? type}) =
      _$ReplyWarningImpl;

  factory _ReplyWarning.fromJson(Map<String, dynamic> json) =
      _$ReplyWarningImpl.fromJson;

  @override
  WarningType? get type;
  @override
  @JsonKey(ignore: true)
  _$$ReplyWarningImplCopyWith<_$ReplyWarningImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
