// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wiki.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WikiCWProxy {
  Wiki body(String body);

  Wiki categoryName(int categoryName);

  Wiki createdAt(DateTime createdAt);

  Wiki creatorId(int creatorId);

  Wiki creatorName(String creatorName);

  Wiki id(int id);

  Wiki isDeleted(bool isDeleted);

  Wiki isLocked(bool isLocked);

  Wiki otherNames(List<String> otherNames);

  Wiki title(String title);

  Wiki updatedAt(DateTime? updatedAt);

  Wiki updaterId(int? updaterId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Wiki(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Wiki(...).copyWith(id: 12, name: "My name")
  /// ````
  Wiki call({
    String? body,
    int? categoryName,
    DateTime? createdAt,
    int? creatorId,
    String? creatorName,
    int? id,
    bool? isDeleted,
    bool? isLocked,
    List<String>? otherNames,
    String? title,
    DateTime? updatedAt,
    int? updaterId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfWiki.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfWiki.copyWith.fieldName(...)`
class _$WikiCWProxyImpl implements _$WikiCWProxy {
  final Wiki _value;

  const _$WikiCWProxyImpl(this._value);

  @override
  Wiki body(String body) => this(body: body);

  @override
  Wiki categoryName(int categoryName) => this(categoryName: categoryName);

  @override
  Wiki createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  Wiki creatorId(int creatorId) => this(creatorId: creatorId);

  @override
  Wiki creatorName(String creatorName) => this(creatorName: creatorName);

  @override
  Wiki id(int id) => this(id: id);

  @override
  Wiki isDeleted(bool isDeleted) => this(isDeleted: isDeleted);

  @override
  Wiki isLocked(bool isLocked) => this(isLocked: isLocked);

  @override
  Wiki otherNames(List<String> otherNames) => this(otherNames: otherNames);

  @override
  Wiki title(String title) => this(title: title);

  @override
  Wiki updatedAt(DateTime? updatedAt) => this(updatedAt: updatedAt);

  @override
  Wiki updaterId(int? updaterId) => this(updaterId: updaterId);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Wiki(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Wiki(...).copyWith(id: 12, name: "My name")
  /// ````
  Wiki call({
    Object? body = const $CopyWithPlaceholder(),
    Object? categoryName = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? creatorId = const $CopyWithPlaceholder(),
    Object? creatorName = const $CopyWithPlaceholder(),
    Object? id = const $CopyWithPlaceholder(),
    Object? isDeleted = const $CopyWithPlaceholder(),
    Object? isLocked = const $CopyWithPlaceholder(),
    Object? otherNames = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? updatedAt = const $CopyWithPlaceholder(),
    Object? updaterId = const $CopyWithPlaceholder(),
  }) {
    return Wiki(
      body: body == const $CopyWithPlaceholder() || body == null
          ? _value.body
          // ignore: cast_nullable_to_non_nullable
          : body as String,
      categoryName:
          categoryName == const $CopyWithPlaceholder() || categoryName == null
              ? _value.categoryName
              // ignore: cast_nullable_to_non_nullable
              : categoryName as int,
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
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      isDeleted: isDeleted == const $CopyWithPlaceholder() || isDeleted == null
          ? _value.isDeleted
          // ignore: cast_nullable_to_non_nullable
          : isDeleted as bool,
      isLocked: isLocked == const $CopyWithPlaceholder() || isLocked == null
          ? _value.isLocked
          // ignore: cast_nullable_to_non_nullable
          : isLocked as bool,
      otherNames:
          otherNames == const $CopyWithPlaceholder() || otherNames == null
              ? _value.otherNames
              // ignore: cast_nullable_to_non_nullable
              : otherNames as List<String>,
      title: title == const $CopyWithPlaceholder() || title == null
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      updatedAt: updatedAt == const $CopyWithPlaceholder()
          ? _value.updatedAt
          // ignore: cast_nullable_to_non_nullable
          : updatedAt as DateTime?,
      updaterId: updaterId == const $CopyWithPlaceholder()
          ? _value.updaterId
          // ignore: cast_nullable_to_non_nullable
          : updaterId as int?,
    );
  }
}

extension $WikiCopyWith on Wiki {
  /// Returns a callable class that can be used as follows: `instanceOfWiki.copyWith(...)` or like so:`instanceOfWiki.copyWith.fieldName(...)`.
  _$WikiCWProxy get copyWith => _$WikiCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Wiki _$WikiFromJson(Map<String, dynamic> json) => Wiki(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      title: json['title'] as String,
      body: json['body'] as String,
      creatorId: json['creator_id'] as int,
      isLocked: json['is_locked'] as bool,
      updaterId: json['updater_id'] as int?,
      isDeleted: json['is_deleted'] as bool,
      otherNames: (json['other_names'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      creatorName: json['creator_name'] as String,
      categoryName: json['category_name'] as int,
    );

Map<String, dynamic> _$WikiToJson(Wiki instance) => <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'title': instance.title,
      'body': instance.body,
      'creator_id': instance.creatorId,
      'is_locked': instance.isLocked,
      'updater_id': instance.updaterId,
      'is_deleted': instance.isDeleted,
      'other_names': instance.otherNames,
      'creator_name': instance.creatorName,
      'category_name': instance.categoryName,
    };
