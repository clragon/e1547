// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TagCWProxy {
  Tag category(int category);

  Tag createdAt(DateTime createdAt);

  Tag id(int id);

  Tag isLocked(bool isLocked);

  Tag name(String name);

  Tag postCount(int postCount);

  Tag relatedTags(String relatedTags);

  Tag relatedTagsUpdatedAt(DateTime relatedTagsUpdatedAt);

  Tag updatedAt(DateTime updatedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Tag(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Tag(...).copyWith(id: 12, name: "My name")
  /// ````
  Tag call({
    int? category,
    DateTime? createdAt,
    int? id,
    bool? isLocked,
    String? name,
    int? postCount,
    String? relatedTags,
    DateTime? relatedTagsUpdatedAt,
    DateTime? updatedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTag.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTag.copyWith.fieldName(...)`
class _$TagCWProxyImpl implements _$TagCWProxy {
  final Tag _value;

  const _$TagCWProxyImpl(this._value);

  @override
  Tag category(int category) => this(category: category);

  @override
  Tag createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  Tag id(int id) => this(id: id);

  @override
  Tag isLocked(bool isLocked) => this(isLocked: isLocked);

  @override
  Tag name(String name) => this(name: name);

  @override
  Tag postCount(int postCount) => this(postCount: postCount);

  @override
  Tag relatedTags(String relatedTags) => this(relatedTags: relatedTags);

  @override
  Tag relatedTagsUpdatedAt(DateTime relatedTagsUpdatedAt) =>
      this(relatedTagsUpdatedAt: relatedTagsUpdatedAt);

  @override
  Tag updatedAt(DateTime updatedAt) => this(updatedAt: updatedAt);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Tag(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Tag(...).copyWith(id: 12, name: "My name")
  /// ````
  Tag call({
    Object? category = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? id = const $CopyWithPlaceholder(),
    Object? isLocked = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? postCount = const $CopyWithPlaceholder(),
    Object? relatedTags = const $CopyWithPlaceholder(),
    Object? relatedTagsUpdatedAt = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
  }) {
    return Tag(
      category: category == const $CopyWithPlaceholder() || category == null
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as int,
      createdAt: createdAt == const $CopyWithPlaceholder() || createdAt == null
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      isLocked: isLocked == const $CopyWithPlaceholder() || isLocked == null
          ? _value.isLocked
          // ignore: cast_nullable_to_non_nullable
          : isLocked as bool,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      postCount: postCount == const $CopyWithPlaceholder() || postCount == null
          ? _value.postCount
          // ignore: cast_nullable_to_non_nullable
          : postCount as int,
      relatedTags:
          relatedTags == const $CopyWithPlaceholder() || relatedTags == null
              ? _value.relatedTags
              // ignore: cast_nullable_to_non_nullable
              : relatedTags as String,
      relatedTagsUpdatedAt:
          relatedTagsUpdatedAt == const $CopyWithPlaceholder() ||
                  relatedTagsUpdatedAt == null
              ? _value.relatedTagsUpdatedAt
              // ignore: cast_nullable_to_non_nullable
              : relatedTagsUpdatedAt as DateTime,
      updatedAt: updatedAt == const $CopyWithPlaceholder() || updatedAt == null
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime,
    );
  }
}

extension $TagCopyWith on Tag {
  /// Returns a callable class that can be used as follows: `instanceOfTag.copyWith(...)` or like so:`instanceOfTag.copyWith.fieldName(...)`.
  _$TagCWProxy get copyWith => _$TagCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tag _$TagFromJson(Map<String, dynamic> json) => Tag(
      id: json['id'] as int,
      name: json['name'] as String,
      postCount: json['post_count'] as int,
      relatedTags: json['related_tags'] as String,
      relatedTagsUpdatedAt:
          DateTime.parse(json['related_tags_updated_at'] as String),
      category: json['category'] as int,
      isLocked: json['is_locked'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$TagToJson(Tag instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'post_count': instance.postCount,
      'related_tags': instance.relatedTags,
      'related_tags_updated_at':
          instance.relatedTagsUpdatedAt.toIso8601String(),
      'category': instance.category,
      'is_locked': instance.isLocked,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
