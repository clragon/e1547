// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'tag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Tag _$TagFromJson(Map<String, dynamic> json) {
  return _Tag.fromJson(json);
}

/// @nodoc
mixin _$Tag {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get postCount => throw _privateConstructorUsedError;
  String get relatedTags => throw _privateConstructorUsedError;
  DateTime get relatedTagsUpdatedAt => throw _privateConstructorUsedError;
  int get category => throw _privateConstructorUsedError;
  bool get isLocked => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TagCopyWith<Tag> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TagCopyWith<$Res> {
  factory $TagCopyWith(Tag value, $Res Function(Tag) then) =
      _$TagCopyWithImpl<$Res, Tag>;
  @useResult
  $Res call(
      {int id,
      String name,
      int postCount,
      String relatedTags,
      DateTime relatedTagsUpdatedAt,
      int category,
      bool isLocked,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$TagCopyWithImpl<$Res, $Val extends Tag> implements $TagCopyWith<$Res> {
  _$TagCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? postCount = null,
    Object? relatedTags = null,
    Object? relatedTagsUpdatedAt = null,
    Object? category = null,
    Object? isLocked = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      postCount: null == postCount
          ? _value.postCount
          : postCount // ignore: cast_nullable_to_non_nullable
              as int,
      relatedTags: null == relatedTags
          ? _value.relatedTags
          : relatedTags // ignore: cast_nullable_to_non_nullable
              as String,
      relatedTagsUpdatedAt: null == relatedTagsUpdatedAt
          ? _value.relatedTagsUpdatedAt
          : relatedTagsUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as int,
      isLocked: null == isLocked
          ? _value.isLocked
          : isLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_TagCopyWith<$Res> implements $TagCopyWith<$Res> {
  factory _$$_TagCopyWith(_$_Tag value, $Res Function(_$_Tag) then) =
      __$$_TagCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      int postCount,
      String relatedTags,
      DateTime relatedTagsUpdatedAt,
      int category,
      bool isLocked,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$_TagCopyWithImpl<$Res> extends _$TagCopyWithImpl<$Res, _$_Tag>
    implements _$$_TagCopyWith<$Res> {
  __$$_TagCopyWithImpl(_$_Tag _value, $Res Function(_$_Tag) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? postCount = null,
    Object? relatedTags = null,
    Object? relatedTagsUpdatedAt = null,
    Object? category = null,
    Object? isLocked = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$_Tag(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      postCount: null == postCount
          ? _value.postCount
          : postCount // ignore: cast_nullable_to_non_nullable
              as int,
      relatedTags: null == relatedTags
          ? _value.relatedTags
          : relatedTags // ignore: cast_nullable_to_non_nullable
              as String,
      relatedTagsUpdatedAt: null == relatedTagsUpdatedAt
          ? _value.relatedTagsUpdatedAt
          : relatedTagsUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as int,
      isLocked: null == isLocked
          ? _value.isLocked
          : isLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Tag implements _Tag {
  const _$_Tag(
      {required this.id,
      required this.name,
      required this.postCount,
      required this.relatedTags,
      required this.relatedTagsUpdatedAt,
      required this.category,
      required this.isLocked,
      required this.createdAt,
      required this.updatedAt});

  factory _$_Tag.fromJson(Map<String, dynamic> json) => _$$_TagFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final int postCount;
  @override
  final String relatedTags;
  @override
  final DateTime relatedTagsUpdatedAt;
  @override
  final int category;
  @override
  final bool isLocked;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Tag(id: $id, name: $name, postCount: $postCount, relatedTags: $relatedTags, relatedTagsUpdatedAt: $relatedTagsUpdatedAt, category: $category, isLocked: $isLocked, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Tag &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.postCount, postCount) ||
                other.postCount == postCount) &&
            (identical(other.relatedTags, relatedTags) ||
                other.relatedTags == relatedTags) &&
            (identical(other.relatedTagsUpdatedAt, relatedTagsUpdatedAt) ||
                other.relatedTagsUpdatedAt == relatedTagsUpdatedAt) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.isLocked, isLocked) ||
                other.isLocked == isLocked) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, postCount, relatedTags,
      relatedTagsUpdatedAt, category, isLocked, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_TagCopyWith<_$_Tag> get copyWith =>
      __$$_TagCopyWithImpl<_$_Tag>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_TagToJson(
      this,
    );
  }
}

abstract class _Tag implements Tag {
  const factory _Tag(
      {required final int id,
      required final String name,
      required final int postCount,
      required final String relatedTags,
      required final DateTime relatedTagsUpdatedAt,
      required final int category,
      required final bool isLocked,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$_Tag;

  factory _Tag.fromJson(Map<String, dynamic> json) = _$_Tag.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  int get postCount;
  @override
  String get relatedTags;
  @override
  DateTime get relatedTagsUpdatedAt;
  @override
  int get category;
  @override
  bool get isLocked;

  @override
  DateTime get createdAt;

  @override
  DateTime get updatedAt;

  @override
  @JsonKey(ignore: true)
  _$$_TagCopyWith<_$_Tag> get copyWith => throw _privateConstructorUsedError;
}

TagSuggestion _$TagSuggestionFromJson(Map<String, dynamic> json) {
  return _TagSuggestion.fromJson(json);
}

/// @nodoc
mixin _$TagSuggestion {
  int get id => throw _privateConstructorUsedError;

  String get name => throw _privateConstructorUsedError;

  int get postCount => throw _privateConstructorUsedError;

  int get category => throw _privateConstructorUsedError;

  String? get antecedentName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TagSuggestionCopyWith<TagSuggestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TagSuggestionCopyWith<$Res> {
  factory $TagSuggestionCopyWith(
          TagSuggestion value, $Res Function(TagSuggestion) then) =
      _$TagSuggestionCopyWithImpl<$Res, TagSuggestion>;

  @useResult
  $Res call(
      {int id,
      String name,
      int postCount,
      int category,
      String? antecedentName});
}

/// @nodoc
class _$TagSuggestionCopyWithImpl<$Res, $Val extends TagSuggestion>
    implements $TagSuggestionCopyWith<$Res> {
  _$TagSuggestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;

  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? postCount = null,
    Object? category = null,
    Object? antecedentName = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      postCount: null == postCount
          ? _value.postCount
          : postCount // ignore: cast_nullable_to_non_nullable
              as int,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as int,
      antecedentName: freezed == antecedentName
          ? _value.antecedentName
          : antecedentName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_TagSuggestionCopyWith<$Res>
    implements $TagSuggestionCopyWith<$Res> {
  factory _$$_TagSuggestionCopyWith(
          _$_TagSuggestion value, $Res Function(_$_TagSuggestion) then) =
      __$$_TagSuggestionCopyWithImpl<$Res>;

  @override
  @useResult
  $Res call(
      {int id,
      String name,
      int postCount,
      int category,
      String? antecedentName});
}

/// @nodoc
class __$$_TagSuggestionCopyWithImpl<$Res>
    extends _$TagSuggestionCopyWithImpl<$Res, _$_TagSuggestion>
    implements _$$_TagSuggestionCopyWith<$Res> {
  __$$_TagSuggestionCopyWithImpl(
      _$_TagSuggestion _value, $Res Function(_$_TagSuggestion) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? postCount = null,
    Object? category = null,
    Object? antecedentName = freezed,
  }) {
    return _then(_$_TagSuggestion(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      postCount: null == postCount
          ? _value.postCount
          : postCount // ignore: cast_nullable_to_non_nullable
              as int,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as int,
      antecedentName: freezed == antecedentName
          ? _value.antecedentName
          : antecedentName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_TagSuggestion implements _TagSuggestion {
  const _$_TagSuggestion(
      {required this.id,
      required this.name,
      required this.postCount,
      required this.category,
      required this.antecedentName});

  factory _$_TagSuggestion.fromJson(Map<String, dynamic> json) =>
      _$$_TagSuggestionFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final int postCount;
  @override
  final int category;
  @override
  final String? antecedentName;

  @override
  String toString() {
    return 'TagSuggestion(id: $id, name: $name, postCount: $postCount, category: $category, antecedentName: $antecedentName)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_TagSuggestion &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.postCount, postCount) ||
                other.postCount == postCount) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.antecedentName, antecedentName) ||
                other.antecedentName == antecedentName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, postCount, category, antecedentName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_TagSuggestionCopyWith<_$_TagSuggestion> get copyWith =>
      __$$_TagSuggestionCopyWithImpl<_$_TagSuggestion>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_TagSuggestionToJson(
      this,
    );
  }
}

abstract class _TagSuggestion implements TagSuggestion {
  const factory _TagSuggestion(
      {required final int id,
      required final String name,
      required final int postCount,
      required final int category,
      required final String? antecedentName}) = _$_TagSuggestion;

  factory _TagSuggestion.fromJson(Map<String, dynamic> json) =
      _$_TagSuggestion.fromJson;

  @override
  int get id;

  @override
  String get name;

  @override
  int get postCount;

  @override
  int get category;

  @override
  String? get antecedentName;

  @override
  @JsonKey(ignore: true)
  _$$_TagSuggestionCopyWith<_$_TagSuggestion> get copyWith =>
      throw _privateConstructorUsedError;
}
