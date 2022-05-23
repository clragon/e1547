// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_suggestion.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TagSuggestionCWProxy {
  TagSuggestion antecedentName(String? antecedentName);

  TagSuggestion category(int category);

  TagSuggestion id(int id);

  TagSuggestion name(String name);

  TagSuggestion postCount(int postCount);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TagSuggestion(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TagSuggestion(...).copyWith(id: 12, name: "My name")
  /// ````
  TagSuggestion call({
    String? antecedentName,
    int? category,
    int? id,
    String? name,
    int? postCount,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTagSuggestion.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTagSuggestion.copyWith.fieldName(...)`
class _$TagSuggestionCWProxyImpl implements _$TagSuggestionCWProxy {
  final TagSuggestion _value;

  const _$TagSuggestionCWProxyImpl(this._value);

  @override
  TagSuggestion antecedentName(String? antecedentName) =>
      this(antecedentName: antecedentName);

  @override
  TagSuggestion category(int category) => this(category: category);

  @override
  TagSuggestion id(int id) => this(id: id);

  @override
  TagSuggestion name(String name) => this(name: name);

  @override
  TagSuggestion postCount(int postCount) => this(postCount: postCount);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TagSuggestion(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TagSuggestion(...).copyWith(id: 12, name: "My name")
  /// ````
  TagSuggestion call({
    Object? antecedentName = const $CopyWithPlaceholder(),
    Object? category = const $CopyWithPlaceholder(),
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? postCount = const $CopyWithPlaceholder(),
  }) {
    return TagSuggestion(
      antecedentName: antecedentName == const $CopyWithPlaceholder()
          ? _value.antecedentName
          // ignore: cast_nullable_to_non_nullable
          : antecedentName as String?,
      category: category == const $CopyWithPlaceholder() || category == null
          ? _value.category
          // ignore: cast_nullable_to_non_nullable
          : category as int,
      id: id == const $CopyWithPlaceholder() || id == null
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as int,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      postCount: postCount == const $CopyWithPlaceholder() || postCount == null
          ? _value.postCount
          // ignore: cast_nullable_to_non_nullable
          : postCount as int,
    );
  }
}

extension $TagSuggestionCopyWith on TagSuggestion {
  /// Returns a callable class that can be used as follows: `instanceOfTagSuggestion.copyWith(...)` or like so:`instanceOfTagSuggestion.copyWith.fieldName(...)`.
  _$TagSuggestionCWProxy get copyWith => _$TagSuggestionCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagSuggestion _$TagSuggestionFromJson(Map<String, dynamic> json) =>
    TagSuggestion(
      id: json['id'] as int,
      name: json['name'] as String,
      postCount: json['post_count'] as int,
      category: json['category'] as int,
      antecedentName: json['antecedent_name'] as String?,
    );

Map<String, dynamic> _$TagSuggestionToJson(TagSuggestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'post_count': instance.postCount,
      'category': instance.category,
      'antecedent_name': instance.antecedentName,
    };
