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
  String get tags => throw _privateConstructorUsedError;
  String? get alias => throw _privateConstructorUsedError;
  FollowType get type => throw _privateConstructorUsedError;
  Map<String, FollowStatus> get statuses => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FollowCopyWith<Follow> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowCopyWith<$Res> {
  factory $FollowCopyWith(Follow value, $Res Function(Follow) then) =
      _$FollowCopyWithImpl<$Res>;
  $Res call(
      {String tags,
      String? alias,
      FollowType type,
      Map<String, FollowStatus> statuses});
}

/// @nodoc
class _$FollowCopyWithImpl<$Res> implements $FollowCopyWith<$Res> {
  _$FollowCopyWithImpl(this._value, this._then);

  final Follow _value;
  // ignore: unused_field
  final $Res Function(Follow) _then;

  @override
  $Res call({
    Object? tags = freezed,
    Object? alias = freezed,
    Object? type = freezed,
    Object? statuses = freezed,
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
      statuses: statuses == freezed
          ? _value.statuses
          : statuses // ignore: cast_nullable_to_non_nullable
              as Map<String, FollowStatus>,
    ));
  }
}

/// @nodoc
abstract class _$$_FollowCopyWith<$Res> implements $FollowCopyWith<$Res> {
  factory _$$_FollowCopyWith(_$_Follow value, $Res Function(_$_Follow) then) =
      __$$_FollowCopyWithImpl<$Res>;
  @override
  $Res call(
      {String tags,
      String? alias,
      FollowType type,
      Map<String, FollowStatus> statuses});
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
    Object? tags = freezed,
    Object? alias = freezed,
    Object? type = freezed,
    Object? statuses = freezed,
  }) {
    return _then(_$_Follow(
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
      statuses: statuses == freezed
          ? _value._statuses
          : statuses // ignore: cast_nullable_to_non_nullable
              as Map<String, FollowStatus>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Follow implements _Follow {
  const _$_Follow(
      {required this.tags,
      this.alias,
      this.type = FollowType.update,
      final Map<String, FollowStatus> statuses = const {}})
      : _statuses = statuses;

  factory _$_Follow.fromJson(Map<String, dynamic> json) =>
      _$$_FollowFromJson(json);

  @override
  final String tags;
  @override
  final String? alias;
  @override
  @JsonKey()
  final FollowType type;
  final Map<String, FollowStatus> _statuses;
  @override
  @JsonKey()
  Map<String, FollowStatus> get statuses {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_statuses);
  }

  @override
  String toString() {
    return 'Follow(tags: $tags, alias: $alias, type: $type, statuses: $statuses)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Follow &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            const DeepCollectionEquality().equals(other.alias, alias) &&
            const DeepCollectionEquality().equals(other.type, type) &&
            const DeepCollectionEquality().equals(other._statuses, _statuses));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(tags),
      const DeepCollectionEquality().hash(alias),
      const DeepCollectionEquality().hash(type),
      const DeepCollectionEquality().hash(_statuses));

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
      {required final String tags,
      final String? alias,
      final FollowType type,
      final Map<String, FollowStatus> statuses}) = _$_Follow;

  factory _Follow.fromJson(Map<String, dynamic> json) = _$_Follow.fromJson;

  @override
  String get tags;
  @override
  String? get alias;
  @override
  FollowType get type;
  @override
  Map<String, FollowStatus> get statuses;
  @override
  @JsonKey(ignore: true)
  _$$_FollowCopyWith<_$_Follow> get copyWith =>
      throw _privateConstructorUsedError;
}

FollowStatus _$FollowStatusFromJson(Map<String, dynamic> json) {
  return _FollowStatus.fromJson(json);
}

/// @nodoc
mixin _$FollowStatus {
  int? get latest => throw _privateConstructorUsedError;
  int? get unseen => throw _privateConstructorUsedError;
  String? get thumbnail => throw _privateConstructorUsedError;
  DateTime? get updated => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FollowStatusCopyWith<FollowStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowStatusCopyWith<$Res> {
  factory $FollowStatusCopyWith(
          FollowStatus value, $Res Function(FollowStatus) then) =
      _$FollowStatusCopyWithImpl<$Res>;
  $Res call({int? latest, int? unseen, String? thumbnail, DateTime? updated});
}

/// @nodoc
class _$FollowStatusCopyWithImpl<$Res> implements $FollowStatusCopyWith<$Res> {
  _$FollowStatusCopyWithImpl(this._value, this._then);

  final FollowStatus _value;
  // ignore: unused_field
  final $Res Function(FollowStatus) _then;

  @override
  $Res call({
    Object? latest = freezed,
    Object? unseen = freezed,
    Object? thumbnail = freezed,
    Object? updated = freezed,
  }) {
    return _then(_value.copyWith(
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
abstract class _$$_FollowStatusCopyWith<$Res>
    implements $FollowStatusCopyWith<$Res> {
  factory _$$_FollowStatusCopyWith(
          _$_FollowStatus value, $Res Function(_$_FollowStatus) then) =
      __$$_FollowStatusCopyWithImpl<$Res>;
  @override
  $Res call({int? latest, int? unseen, String? thumbnail, DateTime? updated});
}

/// @nodoc
class __$$_FollowStatusCopyWithImpl<$Res>
    extends _$FollowStatusCopyWithImpl<$Res>
    implements _$$_FollowStatusCopyWith<$Res> {
  __$$_FollowStatusCopyWithImpl(
      _$_FollowStatus _value, $Res Function(_$_FollowStatus) _then)
      : super(_value, (v) => _then(v as _$_FollowStatus));

  @override
  _$_FollowStatus get _value => super._value as _$_FollowStatus;

  @override
  $Res call({
    Object? latest = freezed,
    Object? unseen = freezed,
    Object? thumbnail = freezed,
    Object? updated = freezed,
  }) {
    return _then(_$_FollowStatus(
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
class _$_FollowStatus implements _FollowStatus {
  const _$_FollowStatus(
      {this.latest, this.unseen, this.thumbnail, this.updated});

  factory _$_FollowStatus.fromJson(Map<String, dynamic> json) =>
      _$$_FollowStatusFromJson(json);

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
    return 'FollowStatus(latest: $latest, unseen: $unseen, thumbnail: $thumbnail, updated: $updated)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_FollowStatus &&
            const DeepCollectionEquality().equals(other.latest, latest) &&
            const DeepCollectionEquality().equals(other.unseen, unseen) &&
            const DeepCollectionEquality().equals(other.thumbnail, thumbnail) &&
            const DeepCollectionEquality().equals(other.updated, updated));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(latest),
      const DeepCollectionEquality().hash(unseen),
      const DeepCollectionEquality().hash(thumbnail),
      const DeepCollectionEquality().hash(updated));

  @JsonKey(ignore: true)
  @override
  _$$_FollowStatusCopyWith<_$_FollowStatus> get copyWith =>
      __$$_FollowStatusCopyWithImpl<_$_FollowStatus>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_FollowStatusToJson(
      this,
    );
  }
}

abstract class _FollowStatus implements FollowStatus {
  const factory _FollowStatus(
      {final int? latest,
      final int? unseen,
      final String? thumbnail,
      final DateTime? updated}) = _$_FollowStatus;

  factory _FollowStatus.fromJson(Map<String, dynamic> json) =
      _$_FollowStatus.fromJson;

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
  _$$_FollowStatusCopyWith<_$_FollowStatus> get copyWith =>
      throw _privateConstructorUsedError;
}
