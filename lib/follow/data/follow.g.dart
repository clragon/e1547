// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FollowCWProxy {
  Follow alias(String? alias);

  Follow statuses(Map<String, FollowStatus> statuses);

  Follow tags(String tags);

  Follow type(FollowType type);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Follow(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Follow(...).copyWith(id: 12, name: "My name")
  /// ````
  Follow call({
    String? alias,
    Map<String, FollowStatus>? statuses,
    String? tags,
    FollowType? type,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFollow.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFollow.copyWith.fieldName(...)`
class _$FollowCWProxyImpl implements _$FollowCWProxy {
  final Follow _value;

  const _$FollowCWProxyImpl(this._value);

  @override
  Follow alias(String? alias) => this(alias: alias);

  @override
  Follow statuses(Map<String, FollowStatus> statuses) =>
      this(statuses: statuses);

  @override
  Follow tags(String tags) => this(tags: tags);

  @override
  Follow type(FollowType type) => this(type: type);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Follow(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Follow(...).copyWith(id: 12, name: "My name")
  /// ````
  Follow call({
    Object? alias = const $CopyWithPlaceholder(),
    Object? statuses = const $CopyWithPlaceholder(),
    Object? tags = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
  }) {
    return Follow(
      alias: alias == const $CopyWithPlaceholder()
          ? _value.alias
          // ignore: cast_nullable_to_non_nullable
          : alias as String?,
      statuses: statuses == const $CopyWithPlaceholder() || statuses == null
          ? _value.statuses
          // ignore: cast_nullable_to_non_nullable
          : statuses as Map<String, FollowStatus>,
      tags: tags == const $CopyWithPlaceholder() || tags == null
          ? _value.tags
          // ignore: cast_nullable_to_non_nullable
          : tags as String,
      type: type == const $CopyWithPlaceholder() || type == null
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as FollowType,
    );
  }
}

extension $FollowCopyWith on Follow {
  /// Returns a callable class that can be used as follows: `instanceOfFollow.copyWith(...)` or like so:`instanceOfFollow.copyWith.fieldName(...)`.
  _$FollowCWProxy get copyWith => _$FollowCWProxyImpl(this);
}

abstract class _$FollowStatusCWProxy {
  FollowStatus latest(int? latest);

  FollowStatus thumbnail(String? thumbnail);

  FollowStatus unseen(int? unseen);

  FollowStatus updated(DateTime? updated);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FollowStatus(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FollowStatus(...).copyWith(id: 12, name: "My name")
  /// ````
  FollowStatus call({
    int? latest,
    String? thumbnail,
    int? unseen,
    DateTime? updated,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFollowStatus.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFollowStatus.copyWith.fieldName(...)`
class _$FollowStatusCWProxyImpl implements _$FollowStatusCWProxy {
  final FollowStatus _value;

  const _$FollowStatusCWProxyImpl(this._value);

  @override
  FollowStatus latest(int? latest) => this(latest: latest);

  @override
  FollowStatus thumbnail(String? thumbnail) => this(thumbnail: thumbnail);

  @override
  FollowStatus unseen(int? unseen) => this(unseen: unseen);

  @override
  FollowStatus updated(DateTime? updated) => this(updated: updated);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FollowStatus(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FollowStatus(...).copyWith(id: 12, name: "My name")
  /// ````
  FollowStatus call({
    Object? latest = const $CopyWithPlaceholder(),
    Object? thumbnail = const $CopyWithPlaceholder(),
    Object? unseen = const $CopyWithPlaceholder(),
    Object? updated = const $CopyWithPlaceholder(),
  }) {
    return FollowStatus(
      latest: latest == const $CopyWithPlaceholder()
          ? _value.latest
          // ignore: cast_nullable_to_non_nullable
          : latest as int?,
      thumbnail: thumbnail == const $CopyWithPlaceholder()
          ? _value.thumbnail
          // ignore: cast_nullable_to_non_nullable
          : thumbnail as String?,
      unseen: unseen == const $CopyWithPlaceholder()
          ? _value.unseen
          // ignore: cast_nullable_to_non_nullable
          : unseen as int?,
      updated: updated == const $CopyWithPlaceholder()
          ? _value.updated
          // ignore: cast_nullable_to_non_nullable
          : updated as DateTime?,
    );
  }
}

extension $FollowStatusCopyWith on FollowStatus {
  /// Returns a callable class that can be used as follows: `instanceOfFollowStatus.copyWith(...)` or like so:`instanceOfFollowStatus.copyWith.fieldName(...)`.
  _$FollowStatusCWProxy get copyWith => _$FollowStatusCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Follow _$FollowFromJson(Map<String, dynamic> json) => Follow(
      tags: json['tags'] as String,
      alias: json['alias'] as String?,
      type: $enumDecodeNullable(_$FollowTypeEnumMap, json['type']) ??
          FollowType.update,
      statuses: (json['statuses'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, FollowStatus.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
    );

Map<String, dynamic> _$FollowToJson(Follow instance) => <String, dynamic>{
      'tags': instance.tags,
      'alias': instance.alias,
      'type': _$FollowTypeEnumMap[instance.type],
      'statuses': instance.statuses,
    };

const _$FollowTypeEnumMap = {
  FollowType.update: 'update',
  FollowType.notify: 'notify',
  FollowType.bookmark: 'bookmark',
};

FollowStatus _$FollowStatusFromJson(Map<String, dynamic> json) => FollowStatus(
      latest: json['latest'] as int?,
      unseen: json['unseen'] as int?,
      thumbnail: json['thumbnail'] as String?,
      updated: json['updated'] == null
          ? null
          : DateTime.parse(json['updated'] as String),
    );

Map<String, dynamic> _$FollowStatusToJson(FollowStatus instance) =>
    <String, dynamic>{
      'latest': instance.latest,
      'unseen': instance.unseen,
      'thumbnail': instance.thumbnail,
      'updated': instance.updated?.toIso8601String(),
    };
