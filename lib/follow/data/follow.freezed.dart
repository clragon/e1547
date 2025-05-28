// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follow.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

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

  /// Serializes this Follow to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Follow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FollowCopyWith<Follow> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowCopyWith<$Res> {
  factory $FollowCopyWith(Follow value, $Res Function(Follow) then) =
      _$FollowCopyWithImpl<$Res, Follow>;
  @useResult
  $Res call({
    int id,
    String tags,
    String? title,
    String? alias,
    FollowType type,
    int? latest,
    int? unseen,
    String? thumbnail,
    DateTime? updated,
  });
}

/// @nodoc
class _$FollowCopyWithImpl<$Res, $Val extends Follow>
    implements $FollowCopyWith<$Res> {
  _$FollowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Follow
  /// with the given fields replaced by the non-null parameter values.
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
    return _then(
      _value.copyWith(
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FollowImplCopyWith<$Res> implements $FollowCopyWith<$Res> {
  factory _$$FollowImplCopyWith(
    _$FollowImpl value,
    $Res Function(_$FollowImpl) then,
  ) = __$$FollowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String tags,
    String? title,
    String? alias,
    FollowType type,
    int? latest,
    int? unseen,
    String? thumbnail,
    DateTime? updated,
  });
}

/// @nodoc
class __$$FollowImplCopyWithImpl<$Res>
    extends _$FollowCopyWithImpl<$Res, _$FollowImpl>
    implements _$$FollowImplCopyWith<$Res> {
  __$$FollowImplCopyWithImpl(
    _$FollowImpl _value,
    $Res Function(_$FollowImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Follow
  /// with the given fields replaced by the non-null parameter values.
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
    return _then(
      _$FollowImpl(
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FollowImpl implements _Follow {
  const _$FollowImpl({
    required this.id,
    required this.tags,
    required this.title,
    required this.alias,
    required this.type,
    required this.latest,
    required this.unseen,
    required this.thumbnail,
    required this.updated,
  });

  factory _$FollowImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowImplFromJson(json);

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowImpl &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    tags,
    title,
    alias,
    type,
    latest,
    unseen,
    thumbnail,
    updated,
  );

  /// Create a copy of Follow
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowImplCopyWith<_$FollowImpl> get copyWith =>
      __$$FollowImplCopyWithImpl<_$FollowImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowImplToJson(this);
  }
}

abstract class _Follow implements Follow {
  const factory _Follow({
    required final int id,
    required final String tags,
    required final String? title,
    required final String? alias,
    required final FollowType type,
    required final int? latest,
    required final int? unseen,
    required final String? thumbnail,
    required final DateTime? updated,
  }) = _$FollowImpl;

  factory _Follow.fromJson(Map<String, dynamic> json) = _$FollowImpl.fromJson;

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

  /// Create a copy of Follow
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FollowImplCopyWith<_$FollowImpl> get copyWith =>
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

  /// Serializes this FollowRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FollowRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FollowRequestCopyWith<FollowRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowRequestCopyWith<$Res> {
  factory $FollowRequestCopyWith(
    FollowRequest value,
    $Res Function(FollowRequest) then,
  ) = _$FollowRequestCopyWithImpl<$Res, FollowRequest>;
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

  /// Create a copy of FollowRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tags = null,
    Object? title = freezed,
    Object? alias = freezed,
    Object? type = null,
  }) {
    return _then(
      _value.copyWith(
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FollowRequestImplCopyWith<$Res>
    implements $FollowRequestCopyWith<$Res> {
  factory _$$FollowRequestImplCopyWith(
    _$FollowRequestImpl value,
    $Res Function(_$FollowRequestImpl) then,
  ) = __$$FollowRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String tags, String? title, String? alias, FollowType type});
}

/// @nodoc
class __$$FollowRequestImplCopyWithImpl<$Res>
    extends _$FollowRequestCopyWithImpl<$Res, _$FollowRequestImpl>
    implements _$$FollowRequestImplCopyWith<$Res> {
  __$$FollowRequestImplCopyWithImpl(
    _$FollowRequestImpl _value,
    $Res Function(_$FollowRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FollowRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tags = null,
    Object? title = freezed,
    Object? alias = freezed,
    Object? type = null,
  }) {
    return _then(
      _$FollowRequestImpl(
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FollowRequestImpl implements _FollowRequest {
  const _$FollowRequestImpl({
    required this.tags,
    this.title,
    this.alias,
    this.type = FollowType.update,
  });

  factory _$FollowRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowRequestImplFromJson(json);

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowRequestImpl &&
            (identical(other.tags, tags) || other.tags == tags) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.alias, alias) || other.alias == alias) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, tags, title, alias, type);

  /// Create a copy of FollowRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowRequestImplCopyWith<_$FollowRequestImpl> get copyWith =>
      __$$FollowRequestImplCopyWithImpl<_$FollowRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowRequestImplToJson(this);
  }
}

abstract class _FollowRequest implements FollowRequest {
  const factory _FollowRequest({
    required final String tags,
    final String? title,
    final String? alias,
    final FollowType type,
  }) = _$FollowRequestImpl;

  factory _FollowRequest.fromJson(Map<String, dynamic> json) =
      _$FollowRequestImpl.fromJson;

  @override
  String get tags;
  @override
  String? get title;
  @override
  String? get alias;
  @override
  FollowType get type;

  /// Create a copy of FollowRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FollowRequestImplCopyWith<_$FollowRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FollowUpdate _$FollowUpdateFromJson(Map<String, dynamic> json) {
  return _FollowUpdate.fromJson(json);
}

/// @nodoc
mixin _$FollowUpdate {
  int get id => throw _privateConstructorUsedError;
  String? get tags => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  FollowType? get type => throw _privateConstructorUsedError;

  /// Serializes this FollowUpdate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FollowUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FollowUpdateCopyWith<FollowUpdate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowUpdateCopyWith<$Res> {
  factory $FollowUpdateCopyWith(
    FollowUpdate value,
    $Res Function(FollowUpdate) then,
  ) = _$FollowUpdateCopyWithImpl<$Res, FollowUpdate>;
  @useResult
  $Res call({int id, String? tags, String? title, FollowType? type});
}

/// @nodoc
class _$FollowUpdateCopyWithImpl<$Res, $Val extends FollowUpdate>
    implements $FollowUpdateCopyWith<$Res> {
  _$FollowUpdateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FollowUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tags = freezed,
    Object? title = freezed,
    Object? type = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            tags: freezed == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as String?,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as FollowType?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FollowUpdateImplCopyWith<$Res>
    implements $FollowUpdateCopyWith<$Res> {
  factory _$$FollowUpdateImplCopyWith(
    _$FollowUpdateImpl value,
    $Res Function(_$FollowUpdateImpl) then,
  ) = __$$FollowUpdateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String? tags, String? title, FollowType? type});
}

/// @nodoc
class __$$FollowUpdateImplCopyWithImpl<$Res>
    extends _$FollowUpdateCopyWithImpl<$Res, _$FollowUpdateImpl>
    implements _$$FollowUpdateImplCopyWith<$Res> {
  __$$FollowUpdateImplCopyWithImpl(
    _$FollowUpdateImpl _value,
    $Res Function(_$FollowUpdateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FollowUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tags = freezed,
    Object? title = freezed,
    Object? type = freezed,
  }) {
    return _then(
      _$FollowUpdateImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        tags: freezed == tags
            ? _value.tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as FollowType?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FollowUpdateImpl implements _FollowUpdate {
  const _$FollowUpdateImpl({
    required this.id,
    this.tags,
    this.title,
    this.type,
  });

  factory _$FollowUpdateImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowUpdateImplFromJson(json);

  @override
  final int id;
  @override
  final String? tags;
  @override
  final String? title;
  @override
  final FollowType? type;

  @override
  String toString() {
    return 'FollowUpdate(id: $id, tags: $tags, title: $title, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowUpdateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tags, tags) || other.tags == tags) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, tags, title, type);

  /// Create a copy of FollowUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowUpdateImplCopyWith<_$FollowUpdateImpl> get copyWith =>
      __$$FollowUpdateImplCopyWithImpl<_$FollowUpdateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowUpdateImplToJson(this);
  }
}

abstract class _FollowUpdate implements FollowUpdate {
  const factory _FollowUpdate({
    required final int id,
    final String? tags,
    final String? title,
    final FollowType? type,
  }) = _$FollowUpdateImpl;

  factory _FollowUpdate.fromJson(Map<String, dynamic> json) =
      _$FollowUpdateImpl.fromJson;

  @override
  int get id;
  @override
  String? get tags;
  @override
  String? get title;
  @override
  FollowType? get type;

  /// Create a copy of FollowUpdate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FollowUpdateImplCopyWith<_$FollowUpdateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
