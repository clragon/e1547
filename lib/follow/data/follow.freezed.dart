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
      _$FollowCopyWithImpl<$Res>;
  $Res call(
      {int id,
      String tags,
      String? title,
      FollowType type,
      int? latest,
      int? unseen,
      String? thumbnail,
      DateTime? updated});
}

/// @nodoc
class _$FollowCopyWithImpl<$Res> implements $FollowCopyWith<$Res> {
  _$FollowCopyWithImpl(this._value, this._then);

  final Follow _value;
  // ignore: unused_field
  final $Res Function(Follow) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? tags = freezed,
    Object? title = freezed,
    Object? type = freezed,
    Object? latest = freezed,
    Object? unseen = freezed,
    Object? thumbnail = freezed,
    Object? updated = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      tags: tags == freezed
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as String,
      title: title == freezed
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      type: type == freezed
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as FollowType,
      latest: latest == freezed
          ? _value.latest
          : latest // ignore: cast_nullable_to_non_nullable
              as int?,
      unseen: unseen == freezed
          ? _value.unseen
          : unseen // ignore: cast_nullable_to_non_nullable
              as int?,
      thumbnail: thumbnail == freezed
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
      updated: updated == freezed
          ? _value.updated
          : updated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
abstract class _$$_FollowCopyWith<$Res> implements $FollowCopyWith<$Res> {
  factory _$$_FollowCopyWith(_$_Follow value, $Res Function(_$_Follow) then) =
      __$$_FollowCopyWithImpl<$Res>;
  @override
  $Res call(
      {int id,
      String tags,
      String? title,
      FollowType type,
      int? latest,
      int? unseen,
      String? thumbnail,
      DateTime? updated});
}

/// @nodoc
class __$$_FollowCopyWithImpl<$Res> extends _$FollowCopyWithImpl<$Res>
    implements _$$_FollowCopyWith<$Res> {
  __$$_FollowCopyWithImpl(_$_Follow _value, $Res Function(_$_Follow) _then)
      : super(_value, (v) => _then(v as _$_Follow));

  @override
  _$_Follow get _value => super._value as _$_Follow;

  @override
  $Res call({
    Object? id = freezed,
    Object? tags = freezed,
    Object? title = freezed,
    Object? type = freezed,
    Object? latest = freezed,
    Object? unseen = freezed,
    Object? thumbnail = freezed,
    Object? updated = freezed,
  }) {
    return _then(_$_Follow(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      tags: tags == freezed
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as String,
      title: title == freezed
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      type: type == freezed
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as FollowType,
      latest: latest == freezed
          ? _value.latest
          : latest // ignore: cast_nullable_to_non_nullable
              as int?,
      unseen: unseen == freezed
          ? _value.unseen
          : unseen // ignore: cast_nullable_to_non_nullable
              as int?,
      thumbnail: thumbnail == freezed
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String?,
      updated: updated == freezed
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
    return 'Follow(id: $id, tags: $tags, title: $title, type: $type, latest: $latest, unseen: $unseen, thumbnail: $thumbnail, updated: $updated)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Follow &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            const DeepCollectionEquality().equals(other.title, title) &&
            const DeepCollectionEquality().equals(other.type, type) &&
            const DeepCollectionEquality().equals(other.latest, latest) &&
            const DeepCollectionEquality().equals(other.unseen, unseen) &&
            const DeepCollectionEquality().equals(other.thumbnail, thumbnail) &&
            const DeepCollectionEquality().equals(other.updated, updated));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(tags),
      const DeepCollectionEquality().hash(title),
      const DeepCollectionEquality().hash(type),
      const DeepCollectionEquality().hash(latest),
      const DeepCollectionEquality().hash(unseen),
      const DeepCollectionEquality().hash(thumbnail),
      const DeepCollectionEquality().hash(updated));

  @JsonKey(ignore: true)
  @override
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
      _$FollowRequestCopyWithImpl<$Res>;

  $Res call({String tags, String? title, FollowType type});
}

/// @nodoc
class _$FollowRequestCopyWithImpl<$Res>
    implements $FollowRequestCopyWith<$Res> {
  _$FollowRequestCopyWithImpl(this._value, this._then);

  final FollowRequest _value;
  // ignore: unused_field
  final $Res Function(FollowRequest) _then;

  @override
  $Res call({
    Object? tags = freezed,
    Object? title = freezed,
    Object? type = freezed,
  }) {
    return _then(_value.copyWith(
      tags: tags == freezed
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as String,
      title: title == freezed
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      type: type == freezed
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as FollowType,
    ));
  }
}

/// @nodoc
abstract class _$$_FollowRequestCopyWith<$Res>
    implements $FollowRequestCopyWith<$Res> {
  factory _$$_FollowRequestCopyWith(
          _$_FollowRequest value, $Res Function(_$_FollowRequest) then) =
      __$$_FollowRequestCopyWithImpl<$Res>;

  @override
  $Res call({String tags, String? title, FollowType type});
}

/// @nodoc
class __$$_FollowRequestCopyWithImpl<$Res>
    extends _$FollowRequestCopyWithImpl<$Res>
    implements _$$_FollowRequestCopyWith<$Res> {
  __$$_FollowRequestCopyWithImpl(
      _$_FollowRequest _value, $Res Function(_$_FollowRequest) _then)
      : super(_value, (v) => _then(v as _$_FollowRequest));

  @override
  _$_FollowRequest get _value => super._value as _$_FollowRequest;

  @override
  $Res call({
    Object? tags = freezed,
    Object? title = freezed,
    Object? type = freezed,
  }) {
    return _then(_$_FollowRequest(
      tags: tags == freezed
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as String,
      title: title == freezed
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      type: type == freezed
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
      {required this.tags, this.title, this.type = FollowType.update});

  factory _$_FollowRequest.fromJson(Map<String, dynamic> json) =>
      _$$_FollowRequestFromJson(json);

  @override
  final String tags;
  @override
  final String? title;
  @override
  @JsonKey()
  final FollowType type;

  @override
  String toString() {
    return 'FollowRequest(tags: $tags, title: $title, type: $type)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_FollowRequest &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            const DeepCollectionEquality().equals(other.title, title) &&
            const DeepCollectionEquality().equals(other.type, type));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(tags),
      const DeepCollectionEquality().hash(title),
      const DeepCollectionEquality().hash(type));

  @JsonKey(ignore: true)
  @override
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
      final FollowType type}) = _$_FollowRequest;

  factory _FollowRequest.fromJson(Map<String, dynamic> json) =
      _$_FollowRequest.fromJson;

  @override
  String get tags;

  @override
  String? get title;

  @override
  FollowType get type;
  @override
  @JsonKey(ignore: true)
  _$$_FollowRequestCopyWith<_$_FollowRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

PrefsFollow _$PrefsFollowFromJson(Map<String, dynamic> json) {
  return _PrefsFollow.fromJson(json);
}

/// @nodoc
mixin _$PrefsFollow {
  String get tags => throw _privateConstructorUsedError;
  String? get alias => throw _privateConstructorUsedError;
  FollowType get type => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PrefsFollowCopyWith<PrefsFollow> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrefsFollowCopyWith<$Res> {
  factory $PrefsFollowCopyWith(
          PrefsFollow value, $Res Function(PrefsFollow) then) =
      _$PrefsFollowCopyWithImpl<$Res>;
  $Res call({String tags, String? alias, FollowType type});
}

/// @nodoc
class _$PrefsFollowCopyWithImpl<$Res> implements $PrefsFollowCopyWith<$Res> {
  _$PrefsFollowCopyWithImpl(this._value, this._then);

  final PrefsFollow _value;
  // ignore: unused_field
  final $Res Function(PrefsFollow) _then;

  @override
  $Res call({
    Object? tags = freezed,
    Object? alias = freezed,
    Object? type = freezed,
  }) {
    return _then(_value.copyWith(
      tags: tags == freezed
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as String,
      alias: alias == freezed
          ? _value.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String?,
      type: type == freezed
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as FollowType,
    ));
  }
}

/// @nodoc
abstract class _$$_PrefsFollowCopyWith<$Res>
    implements $PrefsFollowCopyWith<$Res> {
  factory _$$_PrefsFollowCopyWith(
          _$_PrefsFollow value, $Res Function(_$_PrefsFollow) then) =
      __$$_PrefsFollowCopyWithImpl<$Res>;
  @override
  $Res call({String tags, String? alias, FollowType type});
}

/// @nodoc
class __$$_PrefsFollowCopyWithImpl<$Res> extends _$PrefsFollowCopyWithImpl<$Res>
    implements _$$_PrefsFollowCopyWith<$Res> {
  __$$_PrefsFollowCopyWithImpl(
      _$_PrefsFollow _value, $Res Function(_$_PrefsFollow) _then)
      : super(_value, (v) => _then(v as _$_PrefsFollow));

  @override
  _$_PrefsFollow get _value => super._value as _$_PrefsFollow;

  @override
  $Res call({
    Object? tags = freezed,
    Object? alias = freezed,
    Object? type = freezed,
  }) {
    return _then(_$_PrefsFollow(
      tags: tags == freezed
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as String,
      alias: alias == freezed
          ? _value.alias
          : alias // ignore: cast_nullable_to_non_nullable
              as String?,
      type: type == freezed
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as FollowType,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_PrefsFollow implements _PrefsFollow {
  const _$_PrefsFollow(
      {required this.tags, this.alias, this.type = FollowType.update});

  factory _$_PrefsFollow.fromJson(Map<String, dynamic> json) =>
      _$$_PrefsFollowFromJson(json);

  @override
  final String tags;
  @override
  final String? alias;
  @override
  @JsonKey()
  final FollowType type;

  @override
  String toString() {
    return 'PrefsFollow(tags: $tags, alias: $alias, type: $type)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PrefsFollow &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            const DeepCollectionEquality().equals(other.alias, alias) &&
            const DeepCollectionEquality().equals(other.type, type));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(tags),
      const DeepCollectionEquality().hash(alias),
      const DeepCollectionEquality().hash(type));

  @JsonKey(ignore: true)
  @override
  _$$_PrefsFollowCopyWith<_$_PrefsFollow> get copyWith =>
      __$$_PrefsFollowCopyWithImpl<_$_PrefsFollow>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_PrefsFollowToJson(
      this,
    );
  }
}

abstract class _PrefsFollow implements PrefsFollow {
  const factory _PrefsFollow(
      {required final String tags,
      final String? alias,
      final FollowType type}) = _$_PrefsFollow;

  factory _PrefsFollow.fromJson(Map<String, dynamic> json) =
      _$_PrefsFollow.fromJson;

  @override
  String get tags;
  @override
  String? get alias;
  @override
  FollowType get type;
  @override
  @JsonKey(ignore: true)
  _$$_PrefsFollowCopyWith<_$_PrefsFollow> get copyWith =>
      throw _privateConstructorUsedError;
}
