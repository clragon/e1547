// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TopicCWProxy {
  Topic categoryId(int categoryId);

  Topic createdAt(DateTime createdAt);

  Topic creatorId(int creatorId);

  Topic id(int id);

  Topic isHidden(bool isHidden);

  Topic isLocked(bool isLocked);

  Topic isSticky(bool isSticky);

  Topic responseCount(int responseCount);

  Topic title(String title);

  Topic updatedAt(DateTime updatedAt);

  Topic updaterId(int updaterId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Topic(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Topic(...).copyWith(id: 12, name: "My name")
  /// ````
  Topic call({
    int? categoryId,
    DateTime? createdAt,
    int? creatorId,
    int? id,
    bool? isHidden,
    bool? isLocked,
    bool? isSticky,
    int? responseCount,
    String? title,
    DateTime? updatedAt,
    int? updaterId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTopic.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTopic.copyWith.fieldName(...)`
class _$TopicCWProxyImpl implements _$TopicCWProxy {
  final Topic _value;

  const _$TopicCWProxyImpl(this._value);

  @override
  Topic categoryId(int categoryId) => this(categoryId: categoryId);

  @override
  Topic createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  Topic creatorId(int creatorId) => this(creatorId: creatorId);

  @override
  Topic id(int id) => this(id: id);

  @override
  Topic isHidden(bool isHidden) => this(isHidden: isHidden);

  @override
  Topic isLocked(bool isLocked) => this(isLocked: isLocked);

  @override
  Topic isSticky(bool isSticky) => this(isSticky: isSticky);

  @override
  Topic responseCount(int responseCount) => this(responseCount: responseCount);

  @override
  Topic title(String title) => this(title: title);

  @override
  Topic updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override
  Topic updaterId(int updaterId) => this(updaterId: updaterId);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Topic(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Topic(...).copyWith(id: 12, name: "My name")
  /// ````
  Topic call({
    Object? categoryId = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? creatorId = const $CopyWithPlaceholder(),
    Object? id = const $CopyWithPlaceholder(),
    Object? isHidden = const $CopyWithPlaceholder(),
    Object? isLocked = const $CopyWithPlaceholder(),
    Object? isSticky = const $CopyWithPlaceholder(),
    Object? responseCount = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? updaterId = const $CopyWithPlaceholder(),
  }) {
    return Topic(
      categoryId:
          categoryId == const $CopyWithPlaceholder() || categoryId == null
              ? _value.categoryId
              // ignore: cast_nullable_to_non_nullable
              : categoryId as int,
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
      isLocked: isLocked == const $CopyWithPlaceholder() || isLocked == null
          ? _value.isLocked
          // ignore: cast_nullable_to_non_nullable
          : isLocked as bool,
      isSticky: isSticky == const $CopyWithPlaceholder() || isSticky == null
          ? _value.isSticky
          // ignore: cast_nullable_to_non_nullable
          : isSticky as bool,
      responseCount:
          responseCount == const $CopyWithPlaceholder() || responseCount == null
              ? _value.responseCount
              // ignore: cast_nullable_to_non_nullable
              : responseCount as int,
      title: title == const $CopyWithPlaceholder() || title == null
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      updatedAt: updatedAt == const $CopyWithPlaceholder() || updatedAt == null
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
      updaterId: updaterId == const $CopyWithPlaceholder() || updaterId == null
          ? _value.updaterId
          // ignore: cast_nullable_to_non_nullable
          : updaterId as int,
    );
  }
}

extension $TopicCopyWith on Topic {
  /// Returns a callable class that can be used as follows: `instanceOfTopic.copyWith(...)` or like so:`instanceOfTopic.copyWith.fieldName(...)`.
  _$TopicCWProxy get copyWith => _$TopicCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Topic _$TopicFromJson(Map<String, dynamic> json) => Topic(
      id: json['id'] as int,
      creatorId: json['creator_id'] as int,
      updaterId: json['updater_id'] as int,
      title: json['title'] as String,
      responseCount: json['response_count'] as int,
      isSticky: json['is_sticky'] as bool,
      isLocked: json['is_locked'] as bool,
      isHidden: json['is_hidden'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      categoryId: json['category_id'] as int,
    );

Map<String, dynamic> _$TopicToJson(Topic instance) => <String, dynamic>{
      'id': instance.id,
      'creator_id': instance.creatorId,
      'updater_id': instance.updaterId,
      'title': instance.title,
      'response_count': instance.responseCount,
      'is_sticky': instance.isSticky,
      'is_locked': instance.isLocked,
      'is_hidden': instance.isHidden,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'category_id': instance.categoryId,
    };
