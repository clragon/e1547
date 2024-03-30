// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int? get avatarId => throw _privateConstructorUsedError;
  UserStats? get stats => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call({int id, String name, int? avatarId, UserStats? stats});

  $UserStatsCopyWith<$Res>? get stats;
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarId = freezed,
    Object? stats = freezed,
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
      avatarId: freezed == avatarId
          ? _value.avatarId
          : avatarId // ignore: cast_nullable_to_non_nullable
              as int?,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as UserStats?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserStatsCopyWith<$Res>? get stats {
    if (_value.stats == null) {
      return null;
    }

    return $UserStatsCopyWith<$Res>(_value.stats!, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
          _$UserImpl value, $Res Function(_$UserImpl) then) =
      __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, int? avatarId, UserStats? stats});

  @override
  $UserStatsCopyWith<$Res>? get stats;
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? avatarId = freezed,
    Object? stats = freezed,
  }) {
    return _then(_$UserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      avatarId: freezed == avatarId
          ? _value.avatarId
          : avatarId // ignore: cast_nullable_to_non_nullable
              as int?,
      stats: freezed == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as UserStats?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl(
      {required this.id,
      required this.name,
      required this.avatarId,
      required this.stats});

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final int? avatarId;
  @override
  final UserStats? stats;

  @override
  String toString() {
    return 'User(id: $id, name: $name, avatarId: $avatarId, stats: $stats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarId, avatarId) ||
                other.avatarId == avatarId) &&
            (identical(other.stats, stats) || other.stats == stats));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, avatarId, stats);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(
      this,
    );
  }
}

abstract class _User implements User {
  const factory _User(
      {required final int id,
      required final String name,
      required final int? avatarId,
      required final UserStats? stats}) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  int? get avatarId;
  @override
  UserStats? get stats;
  @override
  @JsonKey(ignore: true)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserStats _$UserStatsFromJson(Map<String, dynamic> json) {
  return _UserStats.fromJson(json);
}

/// @nodoc
mixin _$UserStats {
  DateTime? get createdAt => throw _privateConstructorUsedError;
  String? get levelString => throw _privateConstructorUsedError;
  int? get favoriteCount => throw _privateConstructorUsedError;
  int? get postUpdateCount => throw _privateConstructorUsedError;
  int? get postUploadCount => throw _privateConstructorUsedError;
  int? get forumPostCount => throw _privateConstructorUsedError;
  int? get commentCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserStatsCopyWith<UserStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserStatsCopyWith<$Res> {
  factory $UserStatsCopyWith(UserStats value, $Res Function(UserStats) then) =
      _$UserStatsCopyWithImpl<$Res, UserStats>;
  @useResult
  $Res call(
      {DateTime? createdAt,
      String? levelString,
      int? favoriteCount,
      int? postUpdateCount,
      int? postUploadCount,
      int? forumPostCount,
      int? commentCount});
}

/// @nodoc
class _$UserStatsCopyWithImpl<$Res, $Val extends UserStats>
    implements $UserStatsCopyWith<$Res> {
  _$UserStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? createdAt = freezed,
    Object? levelString = freezed,
    Object? favoriteCount = freezed,
    Object? postUpdateCount = freezed,
    Object? postUploadCount = freezed,
    Object? forumPostCount = freezed,
    Object? commentCount = freezed,
  }) {
    return _then(_value.copyWith(
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      levelString: freezed == levelString
          ? _value.levelString
          : levelString // ignore: cast_nullable_to_non_nullable
              as String?,
      favoriteCount: freezed == favoriteCount
          ? _value.favoriteCount
          : favoriteCount // ignore: cast_nullable_to_non_nullable
              as int?,
      postUpdateCount: freezed == postUpdateCount
          ? _value.postUpdateCount
          : postUpdateCount // ignore: cast_nullable_to_non_nullable
              as int?,
      postUploadCount: freezed == postUploadCount
          ? _value.postUploadCount
          : postUploadCount // ignore: cast_nullable_to_non_nullable
              as int?,
      forumPostCount: freezed == forumPostCount
          ? _value.forumPostCount
          : forumPostCount // ignore: cast_nullable_to_non_nullable
              as int?,
      commentCount: freezed == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserStatsImplCopyWith<$Res>
    implements $UserStatsCopyWith<$Res> {
  factory _$$UserStatsImplCopyWith(
          _$UserStatsImpl value, $Res Function(_$UserStatsImpl) then) =
      __$$UserStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime? createdAt,
      String? levelString,
      int? favoriteCount,
      int? postUpdateCount,
      int? postUploadCount,
      int? forumPostCount,
      int? commentCount});
}

/// @nodoc
class __$$UserStatsImplCopyWithImpl<$Res>
    extends _$UserStatsCopyWithImpl<$Res, _$UserStatsImpl>
    implements _$$UserStatsImplCopyWith<$Res> {
  __$$UserStatsImplCopyWithImpl(
      _$UserStatsImpl _value, $Res Function(_$UserStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? createdAt = freezed,
    Object? levelString = freezed,
    Object? favoriteCount = freezed,
    Object? postUpdateCount = freezed,
    Object? postUploadCount = freezed,
    Object? forumPostCount = freezed,
    Object? commentCount = freezed,
  }) {
    return _then(_$UserStatsImpl(
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      levelString: freezed == levelString
          ? _value.levelString
          : levelString // ignore: cast_nullable_to_non_nullable
              as String?,
      favoriteCount: freezed == favoriteCount
          ? _value.favoriteCount
          : favoriteCount // ignore: cast_nullable_to_non_nullable
              as int?,
      postUpdateCount: freezed == postUpdateCount
          ? _value.postUpdateCount
          : postUpdateCount // ignore: cast_nullable_to_non_nullable
              as int?,
      postUploadCount: freezed == postUploadCount
          ? _value.postUploadCount
          : postUploadCount // ignore: cast_nullable_to_non_nullable
              as int?,
      forumPostCount: freezed == forumPostCount
          ? _value.forumPostCount
          : forumPostCount // ignore: cast_nullable_to_non_nullable
              as int?,
      commentCount: freezed == commentCount
          ? _value.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserStatsImpl implements _UserStats {
  const _$UserStatsImpl(
      {required this.createdAt,
      required this.levelString,
      required this.favoriteCount,
      required this.postUpdateCount,
      required this.postUploadCount,
      required this.forumPostCount,
      required this.commentCount});

  factory _$UserStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserStatsImplFromJson(json);

  @override
  final DateTime? createdAt;
  @override
  final String? levelString;
  @override
  final int? favoriteCount;
  @override
  final int? postUpdateCount;
  @override
  final int? postUploadCount;
  @override
  final int? forumPostCount;
  @override
  final int? commentCount;

  @override
  String toString() {
    return 'UserStats(createdAt: $createdAt, levelString: $levelString, favoriteCount: $favoriteCount, postUpdateCount: $postUpdateCount, postUploadCount: $postUploadCount, forumPostCount: $forumPostCount, commentCount: $commentCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserStatsImpl &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.levelString, levelString) ||
                other.levelString == levelString) &&
            (identical(other.favoriteCount, favoriteCount) ||
                other.favoriteCount == favoriteCount) &&
            (identical(other.postUpdateCount, postUpdateCount) ||
                other.postUpdateCount == postUpdateCount) &&
            (identical(other.postUploadCount, postUploadCount) ||
                other.postUploadCount == postUploadCount) &&
            (identical(other.forumPostCount, forumPostCount) ||
                other.forumPostCount == forumPostCount) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      createdAt,
      levelString,
      favoriteCount,
      postUpdateCount,
      postUploadCount,
      forumPostCount,
      commentCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserStatsImplCopyWith<_$UserStatsImpl> get copyWith =>
      __$$UserStatsImplCopyWithImpl<_$UserStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserStatsImplToJson(
      this,
    );
  }
}

abstract class _UserStats implements UserStats {
  const factory _UserStats(
      {required final DateTime? createdAt,
      required final String? levelString,
      required final int? favoriteCount,
      required final int? postUpdateCount,
      required final int? postUploadCount,
      required final int? forumPostCount,
      required final int? commentCount}) = _$UserStatsImpl;

  factory _UserStats.fromJson(Map<String, dynamic> json) =
      _$UserStatsImpl.fromJson;

  @override
  DateTime? get createdAt;
  @override
  String? get levelString;
  @override
  int? get favoriteCount;
  @override
  int? get postUpdateCount;
  @override
  int? get postUploadCount;
  @override
  int? get forumPostCount;
  @override
  int? get commentCount;
  @override
  @JsonKey(ignore: true)
  _$$UserStatsImplCopyWith<_$UserStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
