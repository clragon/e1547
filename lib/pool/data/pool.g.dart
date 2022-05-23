// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pool.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PoolCWProxy {
  Pool category(Category category);

  Pool createdAt(DateTime createdAt);

  Pool creatorId(int creatorId);

  Pool creatorName(String creatorName);

  Pool description(String description);

  Pool id(int id);

  Pool isActive(bool isActive);

  Pool isDeleted(bool isDeleted);

  Pool name(String name);

  Pool postCount(int postCount);

  Pool postIds(List<int> postIds);

  Pool updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Pool(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Pool(...).copyWith(id: 12, name: "My name")
  /// ````
  Pool call({
    Category? category,
    DateTime? createdAt,
    int? creatorId,
    String? creatorName,
    String? description,
    int? id,
    bool? isActive,
    bool? isDeleted,
    String? name,
    int? postCount,
    List<int>? postIds,
    DateTime? updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPool.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPool.copyWith.fieldName(...)`
class _$PoolCWProxyImpl implements _$PoolCWProxy {
  final Pool _value;

  const _$PoolCWProxyImpl(this._value);

  @override
  Pool category(Category category) => this(category: category);

  @override
  Pool createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  Pool creatorId(int creatorId) => this(creatorId: creatorId);

  @override
  Pool creatorName(String creatorName) => this(creatorName: creatorName);

  @override
  Pool description(String description) => this(description: description);

  @override
  Pool id(int id) => this(id: id);

  @override
  Pool isActive(bool isActive) => this(isActive: isActive);

  @override
  Pool isDeleted(bool isDeleted) => this(isDeleted: isDeleted);

  @override
  Pool name(String name) => this(name: name);

  @override
  Pool postCount(int postCount) => this(postCount: postCount);

  @override
  Pool postIds(List<int> postIds) => this(postIds: postIds);

  @override
  Pool updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Pool(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Pool(...).copyWith(id: 12, name: "My name")
  /// ````
  Pool call({
    Object? category = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? creatorId = const $CopyWithPlaceholder(),
    Object? creatorName = const $CopyWithPlaceholder(),
    Object? description = const $CopyWithPlaceholder(),
    Object? id = const $CopyWithPlaceholder(),
    Object? isActive = const $CopyWithPlaceholder(),
    Object? isDeleted = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? postCount = const $CopyWithPlaceholder(),
    Object? postIds = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return Pool(
      category: category == const $CopyWithPlaceholder() || category == null
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as Category,
      createdAt: createdAt == const $CopyWithPlaceholder() || createdAt == null
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      creatorId: creatorId == const $CopyWithPlaceholder() || creatorId == null
          ? _value.creatorId
          // ignore: cast_nullable_to_non_nullable
          : creatorId as int,
      creatorName:
          creatorName == const $CopyWithPlaceholder() || creatorName == null
              ? _value.creatorName
              // ignore: cast_nullable_to_non_nullable
              : creatorName as String,
      description:
          description == const $CopyWithPlaceholder() || description == null
              ? _value.description
              // ignore: cast_nullable_to_non_nullable
              : description as String,
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      isActive: isActive == const $CopyWithPlaceholder() || isActive == null
          ? _value.isActive
          // ignore: cast_nullable_to_non_nullable
          : isActive as bool,
      isDeleted: isDeleted == const $CopyWithPlaceholder() || isDeleted == null
          ? _value.isDeleted
          // ignore: cast_nullable_to_non_nullable
          : isDeleted as bool,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      postCount: postCount == const $CopyWithPlaceholder() || postCount == null
          ? _value.postCount
          // ignore: cast_nullable_to_non_nullable
          : postCount as int,
      postIds: postIds == const $CopyWithPlaceholder() || postIds == null
          ? _value.postIds
          // ignore: cast_nullable_to_non_nullable
          : postIds as List<int>,
      updatedAt: updatedAt == const $CopyWithPlaceholder() || updatedAt == null
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $PoolCopyWith on Pool {
  /// Returns a callable class that can be used as follows: `instanceOfPool.copyWith(...)` or like so:`instanceOfPool.copyWith.fieldName(...)`.
  _$PoolCWProxy get copyWith => _$PoolCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pool _$PoolFromJson(Map<String, dynamic> json) => Pool(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      creatorId: json['creator_id'] as int,
      description: json['description'] as String,
      isActive: json['is_active'] as bool,
      category: $enumDecode(_$CategoryEnumMap, json['category']),
      isDeleted: json['is_deleted'] as bool,
      postIds:
          (json['post_ids'] as List<dynamic>).map((e) => e as int).toList(),
      creatorName: json['creator_name'] as String,
      postCount: json['post_count'] as int,
    );

Map<String, dynamic> _$PoolToJson(Pool instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'creator_id': instance.creatorId,
      'description': instance.description,
      'is_active': instance.isActive,
      'category': _$CategoryEnumMap[instance.category],
      'is_deleted': instance.isDeleted,
      'post_ids': instance.postIds,
      'creator_name': instance.creatorName,
      'post_count': instance.postCount,
    };

const _$CategoryEnumMap = {
  Category.series: 'series',
  Category.collection: 'collection',
};
