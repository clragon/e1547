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
  List<String> get thumbnails => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get subtitle => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
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
      List<String> thumbnails,
      String? title,
      String? subtitle});
}

/// @nodoc
class _$HistoryCopyWithImpl<$Res, $Val extends History>
    implements $HistoryCopyWith<$Res> {
  _$HistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? visitedAt = null,
    Object? link = null,
    Object? thumbnails = null,
    Object? title = freezed,
    Object? subtitle = freezed,
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
      thumbnails: null == thumbnails
          ? _value.thumbnails
          : thumbnails // ignore: cast_nullable_to_non_nullable
              as List<String>,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      subtitle: freezed == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String?,
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
      List<String> thumbnails,
      String? title,
      String? subtitle});
}

/// @nodoc
class __$$HistoryImplCopyWithImpl<$Res>
    extends _$HistoryCopyWithImpl<$Res, _$HistoryImpl>
    implements _$$HistoryImplCopyWith<$Res> {
  __$$HistoryImplCopyWithImpl(
      _$HistoryImpl _value, $Res Function(_$HistoryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? visitedAt = null,
    Object? link = null,
    Object? thumbnails = null,
    Object? title = freezed,
    Object? subtitle = freezed,
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
      thumbnails: null == thumbnails
          ? _value._thumbnails
          : thumbnails // ignore: cast_nullable_to_non_nullable
              as List<String>,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      subtitle: freezed == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String?,
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
      required final List<String> thumbnails,
      required this.title,
      required this.subtitle})
      : _thumbnails = thumbnails;

  factory _$HistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$HistoryImplFromJson(json);

  @override
  final int id;
  @override
  final DateTime visitedAt;
  @override
  final String link;
  final List<String> _thumbnails;
  @override
  List<String> get thumbnails {
    if (_thumbnails is EqualUnmodifiableListView) return _thumbnails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_thumbnails);
  }

  @override
  final String? title;
  @override
  final String? subtitle;

  @override
  String toString() {
    return 'History(id: $id, visitedAt: $visitedAt, link: $link, thumbnails: $thumbnails, title: $title, subtitle: $subtitle)';
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
            const DeepCollectionEquality()
                .equals(other._thumbnails, _thumbnails) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, visitedAt, link,
      const DeepCollectionEquality().hash(_thumbnails), title, subtitle);

  @JsonKey(ignore: true)
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
      required final List<String> thumbnails,
      required final String? title,
      required final String? subtitle}) = _$HistoryImpl;

  factory _History.fromJson(Map<String, dynamic> json) = _$HistoryImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get visitedAt;
  @override
  String get link;
  @override
  List<String> get thumbnails;
  @override
  String? get title;
  @override
  String? get subtitle;
  @override
  @JsonKey(ignore: true)
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
  List<String> get thumbnails => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get subtitle => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
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
      List<String> thumbnails,
      String? title,
      String? subtitle});
}

/// @nodoc
class _$HistoryRequestCopyWithImpl<$Res, $Val extends HistoryRequest>
    implements $HistoryRequestCopyWith<$Res> {
  _$HistoryRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? visitedAt = null,
    Object? link = null,
    Object? thumbnails = null,
    Object? title = freezed,
    Object? subtitle = freezed,
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
      thumbnails: null == thumbnails
          ? _value.thumbnails
          : thumbnails // ignore: cast_nullable_to_non_nullable
              as List<String>,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      subtitle: freezed == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String?,
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
      List<String> thumbnails,
      String? title,
      String? subtitle});
}

/// @nodoc
class __$$HistoryRequestImplCopyWithImpl<$Res>
    extends _$HistoryRequestCopyWithImpl<$Res, _$HistoryRequestImpl>
    implements _$$HistoryRequestImplCopyWith<$Res> {
  __$$HistoryRequestImplCopyWithImpl(
      _$HistoryRequestImpl _value, $Res Function(_$HistoryRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? visitedAt = null,
    Object? link = null,
    Object? thumbnails = null,
    Object? title = freezed,
    Object? subtitle = freezed,
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
      thumbnails: null == thumbnails
          ? _value._thumbnails
          : thumbnails // ignore: cast_nullable_to_non_nullable
              as List<String>,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      subtitle: freezed == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HistoryRequestImpl implements _HistoryRequest {
  const _$HistoryRequestImpl(
      {required this.visitedAt,
      required this.link,
      final List<String> thumbnails = const [],
      this.title,
      this.subtitle})
      : _thumbnails = thumbnails;

  factory _$HistoryRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$HistoryRequestImplFromJson(json);

  @override
  final DateTime visitedAt;
  @override
  final String link;
  final List<String> _thumbnails;
  @override
  @JsonKey()
  List<String> get thumbnails {
    if (_thumbnails is EqualUnmodifiableListView) return _thumbnails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_thumbnails);
  }

  @override
  final String? title;
  @override
  final String? subtitle;

  @override
  String toString() {
    return 'HistoryRequest(visitedAt: $visitedAt, link: $link, thumbnails: $thumbnails, title: $title, subtitle: $subtitle)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HistoryRequestImpl &&
            (identical(other.visitedAt, visitedAt) ||
                other.visitedAt == visitedAt) &&
            (identical(other.link, link) || other.link == link) &&
            const DeepCollectionEquality()
                .equals(other._thumbnails, _thumbnails) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, visitedAt, link,
      const DeepCollectionEquality().hash(_thumbnails), title, subtitle);

  @JsonKey(ignore: true)
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
      final List<String> thumbnails,
      final String? title,
      final String? subtitle}) = _$HistoryRequestImpl;

  factory _HistoryRequest.fromJson(Map<String, dynamic> json) =
      _$HistoryRequestImpl.fromJson;

  @override
  DateTime get visitedAt;
  @override
  String get link;
  @override
  List<String> get thumbnails;
  @override
  String? get title;
  @override
  String? get subtitle;
  @override
  @JsonKey(ignore: true)
  _$$HistoryRequestImplCopyWith<_$HistoryRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
