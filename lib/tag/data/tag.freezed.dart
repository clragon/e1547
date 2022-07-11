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
      _$TagCopyWithImpl<$Res>;
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
class _$TagCopyWithImpl<$Res> implements $TagCopyWith<$Res> {
  _$TagCopyWithImpl(this._value, this._then);

  final Tag _value;
  // ignore: unused_field
  final $Res Function(Tag) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? postCount = freezed,
    Object? relatedTags = freezed,
    Object? relatedTagsUpdatedAt = freezed,
    Object? category = freezed,
    Object? isLocked = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      postCount: postCount == freezed
          ? _value.postCount
          : postCount // ignore: cast_nullable_to_non_nullable
              as int,
      relatedTags: relatedTags == freezed
          ? _value.relatedTags
          : relatedTags // ignore: cast_nullable_to_non_nullable
              as String,
      relatedTagsUpdatedAt: relatedTagsUpdatedAt == freezed
          ? _value.relatedTagsUpdatedAt
          : relatedTagsUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: category == freezed
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as int,
      isLocked: isLocked == freezed
          ? _value.isLocked
          : isLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: createdAt == freezed
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: updatedAt == freezed
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
abstract class _$$_TagCopyWith<$Res> implements $TagCopyWith<$Res> {
  factory _$$_TagCopyWith(_$_Tag value, $Res Function(_$_Tag) then) =
      __$$_TagCopyWithImpl<$Res>;
  @override
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
class __$$_TagCopyWithImpl<$Res> extends _$TagCopyWithImpl<$Res>
    implements _$$_TagCopyWith<$Res> {
  __$$_TagCopyWithImpl(_$_Tag _value, $Res Function(_$_Tag) _then)
      : super(_value, (v) => _then(v as _$_Tag));

  @override
  _$_Tag get _value => super._value as _$_Tag;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? postCount = freezed,
    Object? relatedTags = freezed,
    Object? relatedTagsUpdatedAt = freezed,
    Object? category = freezed,
    Object? isLocked = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$_Tag(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      postCount: postCount == freezed
          ? _value.postCount
          : postCount // ignore: cast_nullable_to_non_nullable
              as int,
      relatedTags: relatedTags == freezed
          ? _value.relatedTags
          : relatedTags // ignore: cast_nullable_to_non_nullable
              as String,
      relatedTagsUpdatedAt: relatedTagsUpdatedAt == freezed
          ? _value.relatedTagsUpdatedAt
          : relatedTagsUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: category == freezed
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as int,
      isLocked: isLocked == freezed
          ? _value.isLocked
          : isLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: createdAt == freezed
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: updatedAt == freezed
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Tag with DiagnosticableTreeMixin implements _Tag {
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
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Tag(id: $id, name: $name, postCount: $postCount, relatedTags: $relatedTags, relatedTagsUpdatedAt: $relatedTagsUpdatedAt, category: $category, isLocked: $isLocked, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Tag'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('postCount', postCount))
      ..add(DiagnosticsProperty('relatedTags', relatedTags))
      ..add(DiagnosticsProperty('relatedTagsUpdatedAt', relatedTagsUpdatedAt))
      ..add(DiagnosticsProperty('category', category))
      ..add(DiagnosticsProperty('isLocked', isLocked))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Tag &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.name, name) &&
            const DeepCollectionEquality().equals(other.postCount, postCount) &&
            const DeepCollectionEquality()
                .equals(other.relatedTags, relatedTags) &&
            const DeepCollectionEquality()
                .equals(other.relatedTagsUpdatedAt, relatedTagsUpdatedAt) &&
            const DeepCollectionEquality().equals(other.category, category) &&
            const DeepCollectionEquality().equals(other.isLocked, isLocked) &&
            const DeepCollectionEquality().equals(other.createdAt, createdAt) &&
            const DeepCollectionEquality().equals(other.updatedAt, updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(name),
      const DeepCollectionEquality().hash(postCount),
      const DeepCollectionEquality().hash(relatedTags),
      const DeepCollectionEquality().hash(relatedTagsUpdatedAt),
      const DeepCollectionEquality().hash(category),
      const DeepCollectionEquality().hash(isLocked),
      const DeepCollectionEquality().hash(createdAt),
      const DeepCollectionEquality().hash(updatedAt));

  @JsonKey(ignore: true)
  @override
  _$$_TagCopyWith<_$_Tag> get copyWith =>
      __$$_TagCopyWithImpl<_$_Tag>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_TagToJson(this);
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
