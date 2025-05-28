// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'topic.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Topic _$TopicFromJson(Map<String, dynamic> json) {
  return _Topic.fromJson(json);
}

/// @nodoc
mixin _$Topic {
  int get id => throw _privateConstructorUsedError;
  int get creatorId => throw _privateConstructorUsedError;
  String get creator => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get updaterId => throw _privateConstructorUsedError;
  String get updater => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  int get responseCount => throw _privateConstructorUsedError;
  bool get sticky => throw _privateConstructorUsedError;
  bool get locked => throw _privateConstructorUsedError;
  bool get hidden => throw _privateConstructorUsedError;
  int get categoryId => throw _privateConstructorUsedError;

  /// Serializes this Topic to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Topic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TopicCopyWith<Topic> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopicCopyWith<$Res> {
  factory $TopicCopyWith(Topic value, $Res Function(Topic) then) =
      _$TopicCopyWithImpl<$Res, Topic>;
  @useResult
  $Res call({
    int id,
    int creatorId,
    String creator,
    DateTime createdAt,
    int updaterId,
    String updater,
    DateTime updatedAt,
    String title,
    int responseCount,
    bool sticky,
    bool locked,
    bool hidden,
    int categoryId,
  });
}

/// @nodoc
class _$TopicCopyWithImpl<$Res, $Val extends Topic>
    implements $TopicCopyWith<$Res> {
  _$TopicCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Topic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? creatorId = null,
    Object? creator = null,
    Object? createdAt = null,
    Object? updaterId = null,
    Object? updater = null,
    Object? updatedAt = null,
    Object? title = null,
    Object? responseCount = null,
    Object? sticky = null,
    Object? locked = null,
    Object? hidden = null,
    Object? categoryId = null,
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
            updaterId: null == updaterId
                ? _value.updaterId
                : updaterId // ignore: cast_nullable_to_non_nullable
                      as int,
            updater: null == updater
                ? _value.updater
                : updater // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            responseCount: null == responseCount
                ? _value.responseCount
                : responseCount // ignore: cast_nullable_to_non_nullable
                      as int,
            sticky: null == sticky
                ? _value.sticky
                : sticky // ignore: cast_nullable_to_non_nullable
                      as bool,
            locked: null == locked
                ? _value.locked
                : locked // ignore: cast_nullable_to_non_nullable
                      as bool,
            hidden: null == hidden
                ? _value.hidden
                : hidden // ignore: cast_nullable_to_non_nullable
                      as bool,
            categoryId: null == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TopicImplCopyWith<$Res> implements $TopicCopyWith<$Res> {
  factory _$$TopicImplCopyWith(
    _$TopicImpl value,
    $Res Function(_$TopicImpl) then,
  ) = __$$TopicImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int creatorId,
    String creator,
    DateTime createdAt,
    int updaterId,
    String updater,
    DateTime updatedAt,
    String title,
    int responseCount,
    bool sticky,
    bool locked,
    bool hidden,
    int categoryId,
  });
}

/// @nodoc
class __$$TopicImplCopyWithImpl<$Res>
    extends _$TopicCopyWithImpl<$Res, _$TopicImpl>
    implements _$$TopicImplCopyWith<$Res> {
  __$$TopicImplCopyWithImpl(
    _$TopicImpl _value,
    $Res Function(_$TopicImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Topic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? creatorId = null,
    Object? creator = null,
    Object? createdAt = null,
    Object? updaterId = null,
    Object? updater = null,
    Object? updatedAt = null,
    Object? title = null,
    Object? responseCount = null,
    Object? sticky = null,
    Object? locked = null,
    Object? hidden = null,
    Object? categoryId = null,
  }) {
    return _then(
      _$TopicImpl(
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
        updaterId: null == updaterId
            ? _value.updaterId
            : updaterId // ignore: cast_nullable_to_non_nullable
                  as int,
        updater: null == updater
            ? _value.updater
            : updater // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        responseCount: null == responseCount
            ? _value.responseCount
            : responseCount // ignore: cast_nullable_to_non_nullable
                  as int,
        sticky: null == sticky
            ? _value.sticky
            : sticky // ignore: cast_nullable_to_non_nullable
                  as bool,
        locked: null == locked
            ? _value.locked
            : locked // ignore: cast_nullable_to_non_nullable
                  as bool,
        hidden: null == hidden
            ? _value.hidden
            : hidden // ignore: cast_nullable_to_non_nullable
                  as bool,
        categoryId: null == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TopicImpl implements _Topic {
  const _$TopicImpl({
    required this.id,
    required this.creatorId,
    required this.creator,
    required this.createdAt,
    required this.updaterId,
    required this.updater,
    required this.updatedAt,
    required this.title,
    required this.responseCount,
    required this.sticky,
    required this.locked,
    required this.hidden,
    required this.categoryId,
  });

  factory _$TopicImpl.fromJson(Map<String, dynamic> json) =>
      _$$TopicImplFromJson(json);

  @override
  final int id;
  @override
  final int creatorId;
  @override
  final String creator;
  @override
  final DateTime createdAt;
  @override
  final int updaterId;
  @override
  final String updater;
  @override
  final DateTime updatedAt;
  @override
  final String title;
  @override
  final int responseCount;
  @override
  final bool sticky;
  @override
  final bool locked;
  @override
  final bool hidden;
  @override
  final int categoryId;

  @override
  String toString() {
    return 'Topic(id: $id, creatorId: $creatorId, creator: $creator, createdAt: $createdAt, updaterId: $updaterId, updater: $updater, updatedAt: $updatedAt, title: $title, responseCount: $responseCount, sticky: $sticky, locked: $locked, hidden: $hidden, categoryId: $categoryId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopicImpl &&
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
            (identical(other.title, title) || other.title == title) &&
            (identical(other.responseCount, responseCount) ||
                other.responseCount == responseCount) &&
            (identical(other.sticky, sticky) || other.sticky == sticky) &&
            (identical(other.locked, locked) || other.locked == locked) &&
            (identical(other.hidden, hidden) || other.hidden == hidden) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId));
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
    title,
    responseCount,
    sticky,
    locked,
    hidden,
    categoryId,
  );

  /// Create a copy of Topic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TopicImplCopyWith<_$TopicImpl> get copyWith =>
      __$$TopicImplCopyWithImpl<_$TopicImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TopicImplToJson(this);
  }
}

abstract class _Topic implements Topic {
  const factory _Topic({
    required final int id,
    required final int creatorId,
    required final String creator,
    required final DateTime createdAt,
    required final int updaterId,
    required final String updater,
    required final DateTime updatedAt,
    required final String title,
    required final int responseCount,
    required final bool sticky,
    required final bool locked,
    required final bool hidden,
    required final int categoryId,
  }) = _$TopicImpl;

  factory _Topic.fromJson(Map<String, dynamic> json) = _$TopicImpl.fromJson;

  @override
  int get id;
  @override
  int get creatorId;
  @override
  String get creator;
  @override
  DateTime get createdAt;
  @override
  int get updaterId;
  @override
  String get updater;
  @override
  DateTime get updatedAt;
  @override
  String get title;
  @override
  int get responseCount;
  @override
  bool get sticky;
  @override
  bool get locked;
  @override
  bool get hidden;
  @override
  int get categoryId;

  /// Create a copy of Topic
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TopicImplCopyWith<_$TopicImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
