// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

History _$HistoryFromJson(Map<String, dynamic> json) {
  return _History.fromJson(json);
}

/// @nodoc
mixin _$History {
  int get id => throw _privateConstructorUsedError;
  DateTime get visitedAt => throw _privateConstructorUsedError;
  String get link => throw _privateConstructorUsedError;
  HistoryCategory get category => throw _privateConstructorUsedError;
  HistoryType get type => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get subtitle => throw _privateConstructorUsedError;
  List<String> get thumbnails => throw _privateConstructorUsedError;

  /// Serializes this History to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of History
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HistoryCopyWith<History> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HistoryCopyWith<$Res> {
  factory $HistoryCopyWith(History value, $Res Function(History) then) =
      _$HistoryCopyWithImpl<$Res, History>;
  @useResult
  $Res call(
      {int id,
      DateTime visitedAt,
      String link,
      HistoryCategory category,
      HistoryType type,
      String? title,
      String? subtitle,
      List<String> thumbnails});
}

/// @nodoc
class _$HistoryCopyWithImpl<$Res, $Val extends History>
    implements $HistoryCopyWith<$Res> {
  _$HistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of History
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? visitedAt = null,
    Object? link = null,
    Object? category = null,
    Object? type = null,
    Object? title = freezed,
    Object? subtitle = freezed,
    Object? thumbnails = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      visitedAt: null == visitedAt
          ? _value.visitedAt
          : visitedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as HistoryCategory,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as HistoryType,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      subtitle: freezed == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnails: null == thumbnails
          ? _value.thumbnails
          : thumbnails // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HistoryImplCopyWith<$Res> implements $HistoryCopyWith<$Res> {
  factory _$$HistoryImplCopyWith(
          _$HistoryImpl value, $Res Function(_$HistoryImpl) then) =
      __$$HistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime visitedAt,
      String link,
      HistoryCategory category,
      HistoryType type,
      String? title,
      String? subtitle,
      List<String> thumbnails});
}

/// @nodoc
class __$$HistoryImplCopyWithImpl<$Res>
    extends _$HistoryCopyWithImpl<$Res, _$HistoryImpl>
    implements _$$HistoryImplCopyWith<$Res> {
  __$$HistoryImplCopyWithImpl(
      _$HistoryImpl _value, $Res Function(_$HistoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of History
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? visitedAt = null,
    Object? link = null,
    Object? category = null,
    Object? type = null,
    Object? title = freezed,
    Object? subtitle = freezed,
    Object? thumbnails = null,
  }) {
    return _then(_$HistoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      visitedAt: null == visitedAt
          ? _value.visitedAt
          : visitedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as HistoryCategory,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as HistoryType,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      subtitle: freezed == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnails: null == thumbnails
          ? _value._thumbnails
          : thumbnails // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HistoryImpl implements _History {
  const _$HistoryImpl(
      {required this.id,
      required this.visitedAt,
      required this.link,
      required this.category,
      required this.type,
      required this.title,
      required this.subtitle,
      required final List<String> thumbnails})
      : _thumbnails = thumbnails;

  factory _$HistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$HistoryImplFromJson(json);

  @override
  final int id;
  @override
  final DateTime visitedAt;
  @override
  final String link;
  @override
  final HistoryCategory category;
  @override
  final HistoryType type;
  @override
  final String? title;
  @override
  final String? subtitle;
  final List<String> _thumbnails;
  @override
  List<String> get thumbnails {
    if (_thumbnails is EqualUnmodifiableListView) return _thumbnails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_thumbnails);
  }

  @override
  String toString() {
    return 'History(id: $id, visitedAt: $visitedAt, link: $link, category: $category, type: $type, title: $title, subtitle: $subtitle, thumbnails: $thumbnails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HistoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.visitedAt, visitedAt) ||
                other.visitedAt == visitedAt) &&
            (identical(other.link, link) || other.link == link) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            const DeepCollectionEquality()
                .equals(other._thumbnails, _thumbnails));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, visitedAt, link, category,
      type, title, subtitle, const DeepCollectionEquality().hash(_thumbnails));

  /// Create a copy of History
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HistoryImplCopyWith<_$HistoryImpl> get copyWith =>
      __$$HistoryImplCopyWithImpl<_$HistoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HistoryImplToJson(
      this,
    );
  }
}

abstract class _History implements History {
  const factory _History(
      {required final int id,
      required final DateTime visitedAt,
      required final String link,
      required final HistoryCategory category,
      required final HistoryType type,
      required final String? title,
      required final String? subtitle,
      required final List<String> thumbnails}) = _$HistoryImpl;

  factory _History.fromJson(Map<String, dynamic> json) = _$HistoryImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get visitedAt;
  @override
  String get link;
  @override
  HistoryCategory get category;
  @override
  HistoryType get type;
  @override
  String? get title;
  @override
  String? get subtitle;
  @override
  List<String> get thumbnails;

  /// Create a copy of History
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HistoryImplCopyWith<_$HistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HistoryRequest _$HistoryRequestFromJson(Map<String, dynamic> json) {
  return _HistoryRequest.fromJson(json);
}

/// @nodoc
mixin _$HistoryRequest {
  DateTime get visitedAt => throw _privateConstructorUsedError;
  String get link => throw _privateConstructorUsedError;
  HistoryCategory get category => throw _privateConstructorUsedError;
  HistoryType get type => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get subtitle => throw _privateConstructorUsedError;
  List<String> get thumbnails => throw _privateConstructorUsedError;

  /// Serializes this HistoryRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HistoryRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HistoryRequestCopyWith<HistoryRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HistoryRequestCopyWith<$Res> {
  factory $HistoryRequestCopyWith(
          HistoryRequest value, $Res Function(HistoryRequest) then) =
      _$HistoryRequestCopyWithImpl<$Res, HistoryRequest>;
  @useResult
  $Res call(
      {DateTime visitedAt,
      String link,
      HistoryCategory category,
      HistoryType type,
      String? title,
      String? subtitle,
      List<String> thumbnails});
}

/// @nodoc
class _$HistoryRequestCopyWithImpl<$Res, $Val extends HistoryRequest>
    implements $HistoryRequestCopyWith<$Res> {
  _$HistoryRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HistoryRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? visitedAt = null,
    Object? link = null,
    Object? category = null,
    Object? type = null,
    Object? title = freezed,
    Object? subtitle = freezed,
    Object? thumbnails = null,
  }) {
    return _then(_value.copyWith(
      visitedAt: null == visitedAt
          ? _value.visitedAt
          : visitedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as HistoryCategory,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as HistoryType,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      subtitle: freezed == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnails: null == thumbnails
          ? _value.thumbnails
          : thumbnails // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HistoryRequestImplCopyWith<$Res>
    implements $HistoryRequestCopyWith<$Res> {
  factory _$$HistoryRequestImplCopyWith(_$HistoryRequestImpl value,
          $Res Function(_$HistoryRequestImpl) then) =
      __$$HistoryRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime visitedAt,
      String link,
      HistoryCategory category,
      HistoryType type,
      String? title,
      String? subtitle,
      List<String> thumbnails});
}

/// @nodoc
class __$$HistoryRequestImplCopyWithImpl<$Res>
    extends _$HistoryRequestCopyWithImpl<$Res, _$HistoryRequestImpl>
    implements _$$HistoryRequestImplCopyWith<$Res> {
  __$$HistoryRequestImplCopyWithImpl(
      _$HistoryRequestImpl _value, $Res Function(_$HistoryRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of HistoryRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? visitedAt = null,
    Object? link = null,
    Object? category = null,
    Object? type = null,
    Object? title = freezed,
    Object? subtitle = freezed,
    Object? thumbnails = null,
  }) {
    return _then(_$HistoryRequestImpl(
      visitedAt: null == visitedAt
          ? _value.visitedAt
          : visitedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as HistoryCategory,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as HistoryType,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      subtitle: freezed == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnails: null == thumbnails
          ? _value._thumbnails
          : thumbnails // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HistoryRequestImpl implements _HistoryRequest {
  const _$HistoryRequestImpl(
      {required this.visitedAt,
      required this.link,
      required this.category,
      required this.type,
      this.title,
      this.subtitle,
      final List<String> thumbnails = const []})
      : _thumbnails = thumbnails;

  factory _$HistoryRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$HistoryRequestImplFromJson(json);

  @override
  final DateTime visitedAt;
  @override
  final String link;
  @override
  final HistoryCategory category;
  @override
  final HistoryType type;
  @override
  final String? title;
  @override
  final String? subtitle;
  final List<String> _thumbnails;
  @override
  @JsonKey()
  List<String> get thumbnails {
    if (_thumbnails is EqualUnmodifiableListView) return _thumbnails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_thumbnails);
  }

  @override
  String toString() {
    return 'HistoryRequest(visitedAt: $visitedAt, link: $link, category: $category, type: $type, title: $title, subtitle: $subtitle, thumbnails: $thumbnails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HistoryRequestImpl &&
            (identical(other.visitedAt, visitedAt) ||
                other.visitedAt == visitedAt) &&
            (identical(other.link, link) || other.link == link) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            const DeepCollectionEquality()
                .equals(other._thumbnails, _thumbnails));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, visitedAt, link, category, type,
      title, subtitle, const DeepCollectionEquality().hash(_thumbnails));

  /// Create a copy of HistoryRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HistoryRequestImplCopyWith<_$HistoryRequestImpl> get copyWith =>
      __$$HistoryRequestImplCopyWithImpl<_$HistoryRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HistoryRequestImplToJson(
      this,
    );
  }
}

abstract class _HistoryRequest implements HistoryRequest {
  const factory _HistoryRequest(
      {required final DateTime visitedAt,
      required final String link,
      required final HistoryCategory category,
      required final HistoryType type,
      final String? title,
      final String? subtitle,
      final List<String> thumbnails}) = _$HistoryRequestImpl;

  factory _HistoryRequest.fromJson(Map<String, dynamic> json) =
      _$HistoryRequestImpl.fromJson;

  @override
  DateTime get visitedAt;
  @override
  String get link;
  @override
  HistoryCategory get category;
  @override
  HistoryType get type;
  @override
  String? get title;
  @override
  String? get subtitle;
  @override
  List<String> get thumbnails;

  /// Create a copy of HistoryRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HistoryRequestImplCopyWith<_$HistoryRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
