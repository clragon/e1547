// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'follow.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Follow _$FollowFromJson(Map<String, dynamic> json) {
  return _Follow.fromJson(json);
}

/// @nodoc
mixin _$Follow {
  int get id => throw _privateConstructorUsedError;
  String get tags => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get alias => throw _privateConstructorUsedError;
  FollowType get type => throw _privateConstructorUsedError;
  int? get latest => throw _privateConstructorUsedError;
  int? get unseen => throw _privateConstructorUsedError;
  String? get thumbnail => throw _privateConstructorUsedError;
  DateTime? get updated => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FollowCopyWith<Follow> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowCopyWith<$Res> {
  factory $FollowCopyWith(Follow value, $Res Function(Follow) then) =
      _$FollowCopyWithImpl<$Res, Follow>;
  @useResult
  $Res call(
      {int id,
      String tags,
      String? title,
      String? alias,
      FollowType type,
      int? latest,
      int? unseen,
      String? thumbnail,
      DateTime? updated});
}

/// @nodoc
class _$FollowCopyWithImpl<$Res, $Val extends Follow>
    implements $FollowCopyWith<$Res> {
  _$FollowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tags = null,
    Object? title = freezed,
    Object? alias = freezed,
    Object? type = null,
    Object? latest = freezed,
    Object? unseen = freezed,
    Object? thumbnail = freezed,
    Object? updated = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      alias: freezed == alias
          ? _value.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as FollowType,
      latest: freezed == latest
          ? _value.latest
          : latest // ignore: cast_nullable_to_non_nullable
              as int?,
      unseen: freezed == unseen
          ? _value.unseen
          : unseen // ignore: cast_nullable_to_non_nullable
              as int?,
      thumbnail: freezed == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
      updated: freezed == updated
          ? _value.updated
          : updated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_FollowCopyWith<$Res> implements $FollowCopyWith<$Res> {
  factory _$$_FollowCopyWith(_$_Follow value, $Res Function(_$_Follow) then) =
      __$$_FollowCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String tags,
      String? title,
      String? alias,
      FollowType type,
      int? latest,
      int? unseen,
      String? thumbnail,
      DateTime? updated});
}

/// @nodoc
class __$$_FollowCopyWithImpl<$Res>
    extends _$FollowCopyWithImpl<$Res, _$_Follow>
    implements _$$_FollowCopyWith<$Res> {
  __$$_FollowCopyWithImpl(_$_Follow _value, $Res Function(_$_Follow) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tags = null,
    Object? title = freezed,
    Object? alias = freezed,
    Object? type = null,
    Object? latest = freezed,
    Object? unseen = freezed,
    Object? thumbnail = freezed,
    Object? updated = freezed,
  }) {
    return _then(_$_Follow(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      alias: freezed == alias
          ? _value.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as FollowType,
      latest: freezed == latest
          ? _value.latest
          : latest // ignore: cast_nullable_to_non_nullable
              as int?,
      unseen: freezed == unseen
          ? _value.unseen
          : unseen // ignore: cast_nullable_to_non_nullable
              as int?,
      thumbnail: freezed == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
      updated: freezed == updated
          ? _value.updated
          : updated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Follow implements _Follow {
  const _$_Follow(
      {required this.id,
      required this.tags,
      required this.title,
      required this.alias,
      required this.type,
      required this.latest,
      required this.unseen,
      required this.thumbnail,
      required this.updated});

  factory _$_Follow.fromJson(Map<String, dynamic> json) =>
      _$$_FollowFromJson(json);

  @override
  final int id;
  @override
  final String tags;
  @override
  final String? title;
  @override
  final String? alias;
  @override
  final FollowType type;
  @override
  final int? latest;
  @override
  final int? unseen;
  @override
  final String? thumbnail;
  @override
  final DateTime? updated;

  @override
  String toString() {
    return 'Follow(id: $id, tags: $tags, title: $title, alias: $alias, type: $type, latest: $latest, unseen: $unseen, thumbnail: $thumbnail, updated: $updated)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Follow &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tags, tags) || other.tags == tags) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.alias, alias) || other.alias == alias) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.latest, latest) || other.latest == latest) &&
            (identical(other.unseen, unseen) || other.unseen == unseen) &&
            (identical(other.thumbnail, thumbnail) ||
                other.thumbnail == thumbnail) &&
            (identical(other.updated, updated) || other.updated == updated));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, tags, title, alias, type,
      latest, unseen, thumbnail, updated);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_FollowCopyWith<_$_Follow> get copyWith =>
      __$$_FollowCopyWithImpl<_$_Follow>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_FollowToJson(
      this,
    );
  }
}

abstract class _Follow implements Follow {
  const factory _Follow(
      {required final int id,
      required final String tags,
      required final String? title,
      required final String? alias,
      required final FollowType type,
      required final int? latest,
      required final int? unseen,
      required final String? thumbnail,
      required final DateTime? updated}) = _$_Follow;

  factory _Follow.fromJson(Map<String, dynamic> json) = _$_Follow.fromJson;

  @override
  int get id;
  @override
  String get tags;
  @override
  String? get title;
  @override
  String? get alias;
  @override
  FollowType get type;
  @override
  int? get latest;
  @override
  int? get unseen;
  @override
  String? get thumbnail;
  @override
  DateTime? get updated;
  @override
  @JsonKey(ignore: true)
  _$$_FollowCopyWith<_$_Follow> get copyWith =>
      throw _privateConstructorUsedError;
}

FollowRequest _$FollowRequestFromJson(Map<String, dynamic> json) {
  return _FollowRequest.fromJson(json);
}

/// @nodoc
mixin _$FollowRequest {
  String get tags => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get alias => throw _privateConstructorUsedError;
  FollowType get type => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FollowRequestCopyWith<FollowRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowRequestCopyWith<$Res> {
  factory $FollowRequestCopyWith(
          FollowRequest value, $Res Function(FollowRequest) then) =
      _$FollowRequestCopyWithImpl<$Res, FollowRequest>;
  @useResult
  $Res call({String tags, String? title, String? alias, FollowType type});
}

/// @nodoc
class _$FollowRequestCopyWithImpl<$Res, $Val extends FollowRequest>
    implements $FollowRequestCopyWith<$Res> {
  _$FollowRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tags = null,
    Object? title = freezed,
    Object? alias = freezed,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      alias: freezed == alias
          ? _value.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as FollowType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_FollowRequestCopyWith<$Res>
    implements $FollowRequestCopyWith<$Res> {
  factory _$$_FollowRequestCopyWith(
          _$_FollowRequest value, $Res Function(_$_FollowRequest) then) =
      __$$_FollowRequestCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String tags, String? title, String? alias, FollowType type});
}

/// @nodoc
class __$$_FollowRequestCopyWithImpl<$Res>
    extends _$FollowRequestCopyWithImpl<$Res, _$_FollowRequest>
    implements _$$_FollowRequestCopyWith<$Res> {
  __$$_FollowRequestCopyWithImpl(
      _$_FollowRequest _value, $Res Function(_$_FollowRequest) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tags = null,
    Object? title = freezed,
    Object? alias = freezed,
    Object? type = null,
  }) {
    return _then(_$_FollowRequest(
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      alias: freezed == alias
          ? _value.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as FollowType,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_FollowRequest implements _FollowRequest {
  const _$_FollowRequest(
      {required this.tags,
      this.title,
      this.alias,
      this.type = FollowType.update});

  factory _$_FollowRequest.fromJson(Map<String, dynamic> json) =>
      _$$_FollowRequestFromJson(json);

  @override
  final String tags;
  @override
  final String? title;
  @override
  final String? alias;
  @override
  @JsonKey()
  final FollowType type;

  @override
  String toString() {
    return 'FollowRequest(tags: $tags, title: $title, alias: $alias, type: $type)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_FollowRequest &&
            (identical(other.tags, tags) || other.tags == tags) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.alias, alias) || other.alias == alias) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, tags, title, alias, type);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_FollowRequestCopyWith<_$_FollowRequest> get copyWith =>
      __$$_FollowRequestCopyWithImpl<_$_FollowRequest>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_FollowRequestToJson(
      this,
    );
  }
}

abstract class _FollowRequest implements FollowRequest {
  const factory _FollowRequest(
      {required final String tags,
      final String? title,
      final String? alias,
      final FollowType type}) = _$_FollowRequest;

  factory _FollowRequest.fromJson(Map<String, dynamic> json) =
      _$_FollowRequest.fromJson;

  @override
  String get tags;
  @override
  String? get title;
  @override
  String? get alias;
  @override
  FollowType get type;
  @override
  @JsonKey(ignore: true)
  _$$_FollowRequestCopyWith<_$_FollowRequest> get copyWith =>
      throw _privateConstructorUsedError;
}
