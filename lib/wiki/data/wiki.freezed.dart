// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wiki.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Wiki _$WikiFromJson(Map<String, dynamic> json) {
  return _Wiki.fromJson(json);
}

/// @nodoc
mixin _$Wiki {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  int get categoryId => throw _privateConstructorUsedError;
  List<String>? get otherNames => throw _privateConstructorUsedError;
  bool? get isLocked => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WikiCopyWith<Wiki> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WikiCopyWith<$Res> {
  factory $WikiCopyWith(Wiki value, $Res Function(Wiki) then) =
      _$WikiCopyWithImpl<$Res, Wiki>;
  @useResult
  $Res call(
      {int id,
      String title,
      String body,
      DateTime createdAt,
      DateTime? updatedAt,
      int categoryId,
      List<String>? otherNames,
      bool? isLocked});
}

/// @nodoc
class _$WikiCopyWithImpl<$Res, $Val extends Wiki>
    implements $WikiCopyWith<$Res> {
  _$WikiCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? categoryId = null,
    Object? otherNames = freezed,
    Object? isLocked = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int,
      otherNames: freezed == otherNames
          ? _value.otherNames
          : otherNames // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isLocked: freezed == isLocked
          ? _value.isLocked
          : isLocked // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WikiImplCopyWith<$Res> implements $WikiCopyWith<$Res> {
  factory _$$WikiImplCopyWith(
          _$WikiImpl value, $Res Function(_$WikiImpl) then) =
      __$$WikiImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      String body,
      DateTime createdAt,
      DateTime? updatedAt,
      int categoryId,
      List<String>? otherNames,
      bool? isLocked});
}

/// @nodoc
class __$$WikiImplCopyWithImpl<$Res>
    extends _$WikiCopyWithImpl<$Res, _$WikiImpl>
    implements _$$WikiImplCopyWith<$Res> {
  __$$WikiImplCopyWithImpl(_$WikiImpl _value, $Res Function(_$WikiImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? body = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? categoryId = null,
    Object? otherNames = freezed,
    Object? isLocked = freezed,
  }) {
    return _then(_$WikiImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int,
      otherNames: freezed == otherNames
          ? _value._otherNames
          : otherNames // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isLocked: freezed == isLocked
          ? _value.isLocked
          : isLocked // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WikiImpl implements _Wiki {
  const _$WikiImpl(
      {required this.id,
      required this.title,
      required this.body,
      required this.createdAt,
      this.updatedAt,
      required this.categoryId,
      final List<String>? otherNames,
      this.isLocked})
      : _otherNames = otherNames;

  factory _$WikiImpl.fromJson(Map<String, dynamic> json) =>
      _$$WikiImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String body;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final int categoryId;
  final List<String>? _otherNames;
  @override
  List<String>? get otherNames {
    final value = _otherNames;
    if (value == null) return null;
    if (_otherNames is EqualUnmodifiableListView) return _otherNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final bool? isLocked;

  @override
  String toString() {
    return 'Wiki(id: $id, title: $title, body: $body, createdAt: $createdAt, updatedAt: $updatedAt, categoryId: $categoryId, otherNames: $otherNames, isLocked: $isLocked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WikiImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            const DeepCollectionEquality()
                .equals(other._otherNames, _otherNames) &&
            (identical(other.isLocked, isLocked) ||
                other.isLocked == isLocked));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      body,
      createdAt,
      updatedAt,
      categoryId,
      const DeepCollectionEquality().hash(_otherNames),
      isLocked);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WikiImplCopyWith<_$WikiImpl> get copyWith =>
      __$$WikiImplCopyWithImpl<_$WikiImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WikiImplToJson(
      this,
    );
  }
}

abstract class _Wiki implements Wiki {
  const factory _Wiki(
      {required final int id,
      required final String title,
      required final String body,
      required final DateTime createdAt,
      final DateTime? updatedAt,
      required final int categoryId,
      final List<String>? otherNames,
      final bool? isLocked}) = _$WikiImpl;

  factory _Wiki.fromJson(Map<String, dynamic> json) = _$WikiImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  String get body;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  int get categoryId;
  @override
  List<String>? get otherNames;
  @override
  bool? get isLocked;
  @override
  @JsonKey(ignore: true)
  _$$WikiImplCopyWith<_$WikiImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
