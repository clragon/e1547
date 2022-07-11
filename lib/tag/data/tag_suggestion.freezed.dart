// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'tag_suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

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
      _$TagSuggestionCopyWithImpl<$Res>;
  $Res call(
      {int id,
      String name,
      int postCount,
      int category,
      String? antecedentName});
}

/// @nodoc
class _$TagSuggestionCopyWithImpl<$Res>
    implements $TagSuggestionCopyWith<$Res> {
  _$TagSuggestionCopyWithImpl(this._value, this._then);

  final TagSuggestion _value;
  // ignore: unused_field
  final $Res Function(TagSuggestion) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? postCount = freezed,
    Object? category = freezed,
    Object? antecedentName = freezed,
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
      category: category == freezed
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as int,
      antecedentName: antecedentName == freezed
          ? _value.antecedentName
          : antecedentName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
abstract class _$$_TagSuggestionCopyWith<$Res>
    implements $TagSuggestionCopyWith<$Res> {
  factory _$$_TagSuggestionCopyWith(
          _$_TagSuggestion value, $Res Function(_$_TagSuggestion) then) =
      __$$_TagSuggestionCopyWithImpl<$Res>;
  @override
  $Res call(
      {int id,
      String name,
      int postCount,
      int category,
      String? antecedentName});
}

/// @nodoc
class __$$_TagSuggestionCopyWithImpl<$Res>
    extends _$TagSuggestionCopyWithImpl<$Res>
    implements _$$_TagSuggestionCopyWith<$Res> {
  __$$_TagSuggestionCopyWithImpl(
      _$_TagSuggestion _value, $Res Function(_$_TagSuggestion) _then)
      : super(_value, (v) => _then(v as _$_TagSuggestion));

  @override
  _$_TagSuggestion get _value => super._value as _$_TagSuggestion;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? postCount = freezed,
    Object? category = freezed,
    Object? antecedentName = freezed,
  }) {
    return _then(_$_TagSuggestion(
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
      category: category == freezed
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as int,
      antecedentName: antecedentName == freezed
          ? _value.antecedentName
          : antecedentName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_TagSuggestion with DiagnosticableTreeMixin implements _TagSuggestion {
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
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TagSuggestion(id: $id, name: $name, postCount: $postCount, category: $category, antecedentName: $antecedentName)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TagSuggestion'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('postCount', postCount))
      ..add(DiagnosticsProperty('category', category))
      ..add(DiagnosticsProperty('antecedentName', antecedentName));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_TagSuggestion &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.name, name) &&
            const DeepCollectionEquality().equals(other.postCount, postCount) &&
            const DeepCollectionEquality().equals(other.category, category) &&
            const DeepCollectionEquality()
                .equals(other.antecedentName, antecedentName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(name),
      const DeepCollectionEquality().hash(postCount),
      const DeepCollectionEquality().hash(category),
      const DeepCollectionEquality().hash(antecedentName));

  @JsonKey(ignore: true)
  @override
  _$$_TagSuggestionCopyWith<_$_TagSuggestion> get copyWith =>
      __$$_TagSuggestionCopyWithImpl<_$_TagSuggestion>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_TagSuggestionToJson(this);
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
