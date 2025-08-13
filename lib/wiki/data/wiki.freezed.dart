// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wiki.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Wiki {

 int get id; String get title; String get body; DateTime get createdAt; DateTime? get updatedAt; List<String>? get otherNames; bool? get isLocked;
/// Create a copy of Wiki
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WikiCopyWith<Wiki> get copyWith => _$WikiCopyWithImpl<Wiki>(this as Wiki, _$identity);

  /// Serializes this Wiki to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Wiki&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.otherNames, otherNames)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,body,createdAt,updatedAt,const DeepCollectionEquality().hash(otherNames),isLocked);

@override
String toString() {
  return 'Wiki(id: $id, title: $title, body: $body, createdAt: $createdAt, updatedAt: $updatedAt, otherNames: $otherNames, isLocked: $isLocked)';
}


}

/// @nodoc
abstract mixin class $WikiCopyWith<$Res>  {
  factory $WikiCopyWith(Wiki value, $Res Function(Wiki) _then) = _$WikiCopyWithImpl;
@useResult
$Res call({
 int id, String title, String body, DateTime createdAt, DateTime? updatedAt, List<String>? otherNames, bool? isLocked
});




}
/// @nodoc
class _$WikiCopyWithImpl<$Res>
    implements $WikiCopyWith<$Res> {
  _$WikiCopyWithImpl(this._self, this._then);

  final Wiki _self;
  final $Res Function(Wiki) _then;

/// Create a copy of Wiki
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? body = null,Object? createdAt = null,Object? updatedAt = freezed,Object? otherNames = freezed,Object? isLocked = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,otherNames: freezed == otherNames ? _self.otherNames : otherNames // ignore: cast_nullable_to_non_nullable
as List<String>?,isLocked: freezed == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _Wiki implements Wiki {
  const _Wiki({required this.id, required this.title, required this.body, required this.createdAt, this.updatedAt, final  List<String>? otherNames, this.isLocked}): _otherNames = otherNames;
  factory _Wiki.fromJson(Map<String, dynamic> json) => _$WikiFromJson(json);

@override final  int id;
@override final  String title;
@override final  String body;
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;
 final  List<String>? _otherNames;
@override List<String>? get otherNames {
  final value = _otherNames;
  if (value == null) return null;
  if (_otherNames is EqualUnmodifiableListView) return _otherNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  bool? isLocked;

/// Create a copy of Wiki
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WikiCopyWith<_Wiki> get copyWith => __$WikiCopyWithImpl<_Wiki>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WikiToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Wiki&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._otherNames, _otherNames)&&(identical(other.isLocked, isLocked) || other.isLocked == isLocked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,body,createdAt,updatedAt,const DeepCollectionEquality().hash(_otherNames),isLocked);

@override
String toString() {
  return 'Wiki(id: $id, title: $title, body: $body, createdAt: $createdAt, updatedAt: $updatedAt, otherNames: $otherNames, isLocked: $isLocked)';
}


}

/// @nodoc
abstract mixin class _$WikiCopyWith<$Res> implements $WikiCopyWith<$Res> {
  factory _$WikiCopyWith(_Wiki value, $Res Function(_Wiki) _then) = __$WikiCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String body, DateTime createdAt, DateTime? updatedAt, List<String>? otherNames, bool? isLocked
});




}
/// @nodoc
class __$WikiCopyWithImpl<$Res>
    implements _$WikiCopyWith<$Res> {
  __$WikiCopyWithImpl(this._self, this._then);

  final _Wiki _self;
  final $Res Function(_Wiki) _then;

/// Create a copy of Wiki
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? body = null,Object? createdAt = null,Object? updatedAt = freezed,Object? otherNames = freezed,Object? isLocked = freezed,}) {
  return _then(_Wiki(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,otherNames: freezed == otherNames ? _self._otherNames : otherNames // ignore: cast_nullable_to_non_nullable
as List<String>?,isLocked: freezed == isLocked ? _self.isLocked : isLocked // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
