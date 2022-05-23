// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reply.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ReplyCWProxy {
  Reply body(String body);

  Reply createdAt(DateTime createdAt);

  Reply creatorId(int creatorId);

  Reply id(int id);

  Reply isHidden(bool isHidden);

  Reply topicId(int topicId);

  Reply updatedAt(DateTime updatedAt);

  Reply updaterId(int? updaterId);

  Reply warningType(WarningType warningType);

  Reply warningUserId(int? warningUserId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Reply(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Reply(...).copyWith(id: 12, name: "My name")
  /// ````
  Reply call({
    String? body,
    DateTime? createdAt,
    int? creatorId,
    int? id,
    bool? isHidden,
    int? topicId,
    DateTime? updatedAt,
    int? updaterId,
    WarningType? warningType,
    int? warningUserId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfReply.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfReply.copyWith.fieldName(...)`
class _$ReplyCWProxyImpl implements _$ReplyCWProxy {
  final Reply _value;

  const _$ReplyCWProxyImpl(this._value);

  @override
  Reply body(String body) => this(body: body);

  @override
  Reply createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  Reply creatorId(int creatorId) => this(creatorId: creatorId);

  @override
  Reply id(int id) => this(id: id);

  @override
  Reply isHidden(bool isHidden) => this(isHidden: isHidden);

  @override
  Reply topicId(int topicId) => this(topicId: topicId);

  @override
  Reply updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  Reply updaterId(int? updaterId) => this(updaterId: updaterId);

  @override
  Reply warningType(WarningType warningType) => this(warningType: warningType);

  @override
  Reply warningUserId(int? warningUserId) => this(warningUserId: warningUserId);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Reply(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Reply(...).copyWith(id: 12, name: "My name")
  /// ````
  Reply call({
    Object? body = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? creatorId = const $CopyWithPlaceholder(),
    Object? id = const $CopyWithPlaceholder(),
    Object? isHidden = const $CopyWithPlaceholder(),
    Object? topicId = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? updaterId = const $CopyWithPlaceholder(),
    Object? warningType = const $CopyWithPlaceholder(),
    Object? warningUserId = const $CopyWithPlaceholder(),
  }) {
    return Reply(
      body: body == const $CopyWithPlaceholder() || body == null
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String,
      createdAt: createdAt == const $CopyWithPlaceholder() || createdAt == null
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      creatorId: creatorId == const $CopyWithPlaceholder() || creatorId == null
          ? _value.creatorId
          // ignore: cast_nullable_to_non_nullable
          : creatorId as int,
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      isHidden: isHidden == const $CopyWithPlaceholder() || isHidden == null
          ? _value.isHidden
          // ignore: cast_nullable_to_non_nullable
          : isHidden as bool,
      topicId: topicId == const $CopyWithPlaceholder() || topicId == null
          ? _value.topicId
          // ignore: cast_nullable_to_non_nullable
          : topicId as int,
      updatedAt: updatedAt == const $CopyWithPlaceholder() || updatedAt == null
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
      updaterId: updaterId == const $CopyWithPlaceholder()
          ? _value.updaterId
          // ignore: cast_nullable_to_non_nullable
          : updaterId as int?,
      warningType:
          warningType == const $CopyWithPlaceholder() || warningType == null
              ? _value.warningType
              // ignore: cast_nullable_to_non_nullable
              : warningType as WarningType,
      warningUserId: warningUserId == const $CopyWithPlaceholder()
          ? _value.warningUserId
          // ignore: cast_nullable_to_non_nullable
          : warningUserId as int?,
    );
  }
}

extension $ReplyCopyWith on Reply {
  /// Returns a callable class that can be used as follows: `instanceOfReply.copyWith(...)` or like so:`instanceOfReply.copyWith.fieldName(...)`.
  _$ReplyCWProxy get copyWith => _$ReplyCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reply _$ReplyFromJson(Map<String, dynamic> json) => Reply(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      body: json['body'] as String,
      creatorId: json['creator_id'] as int,
      updaterId: json['updater_id'] as int?,
      topicId: json['topic_id'] as int,
      isHidden: json['is_hidden'] as bool,
      warningType: $enumDecode(_$WarningTypeEnumMap, json['warning_type']),
      warningUserId: json['warning_user_id'] as int?,
    );

Map<String, dynamic> _$ReplyToJson(Reply instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'body': instance.body,
      'creator_id': instance.creatorId,
      'updater_id': instance.updaterId,
      'topic_id': instance.topicId,
      'is_hidden': instance.isHidden,
      'warning_type': _$WarningTypeEnumMap[instance.warningType],
      'warning_user_id': instance.warningUserId,
    };

const _$WarningTypeEnumMap = {
  WarningType.warning: 'warning',
  WarningType.record: 'record',
  WarningType.ban: 'ban',
};
