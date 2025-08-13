// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$History {

 int get id; DateTime get visitedAt; String get link; HistoryCategory get category; HistoryType get type; String? get title; String? get subtitle; List<String> get thumbnails;
/// Create a copy of History
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoryCopyWith<History> get copyWith => _$HistoryCopyWithImpl<History>(this as History, _$identity);

  /// Serializes this History to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is History&&(identical(other.id, id) || other.id == id)&&(identical(other.visitedAt, visitedAt) || other.visitedAt == visitedAt)&&(identical(other.link, link) || other.link == link)&&(identical(other.category, category) || other.category == category)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&const DeepCollectionEquality().equals(other.thumbnails, thumbnails));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,visitedAt,link,category,type,title,subtitle,const DeepCollectionEquality().hash(thumbnails));

@override
String toString() {
  return 'History(id: $id, visitedAt: $visitedAt, link: $link, category: $category, type: $type, title: $title, subtitle: $subtitle, thumbnails: $thumbnails)';
}


}

/// @nodoc
abstract mixin class $HistoryCopyWith<$Res>  {
  factory $HistoryCopyWith(History value, $Res Function(History) _then) = _$HistoryCopyWithImpl;
@useResult
$Res call({
 int id, DateTime visitedAt, String link, HistoryCategory category, HistoryType type, String? title, String? subtitle, List<String> thumbnails
});




}
/// @nodoc
class _$HistoryCopyWithImpl<$Res>
    implements $HistoryCopyWith<$Res> {
  _$HistoryCopyWithImpl(this._self, this._then);

  final History _self;
  final $Res Function(History) _then;

/// Create a copy of History
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? visitedAt = null,Object? link = null,Object? category = null,Object? type = null,Object? title = freezed,Object? subtitle = freezed,Object? thumbnails = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,visitedAt: null == visitedAt ? _self.visitedAt : visitedAt // ignore: cast_nullable_to_non_nullable
as DateTime,link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as HistoryCategory,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as HistoryType,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,thumbnails: null == thumbnails ? _self.thumbnails : thumbnails // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _History implements History {
  const _History({required this.id, required this.visitedAt, required this.link, required this.category, required this.type, required this.title, required this.subtitle, required final  List<String> thumbnails}): _thumbnails = thumbnails;
  factory _History.fromJson(Map<String, dynamic> json) => _$HistoryFromJson(json);

@override final  int id;
@override final  DateTime visitedAt;
@override final  String link;
@override final  HistoryCategory category;
@override final  HistoryType type;
@override final  String? title;
@override final  String? subtitle;
 final  List<String> _thumbnails;
@override List<String> get thumbnails {
  if (_thumbnails is EqualUnmodifiableListView) return _thumbnails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_thumbnails);
}


/// Create a copy of History
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistoryCopyWith<_History> get copyWith => __$HistoryCopyWithImpl<_History>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HistoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _History&&(identical(other.id, id) || other.id == id)&&(identical(other.visitedAt, visitedAt) || other.visitedAt == visitedAt)&&(identical(other.link, link) || other.link == link)&&(identical(other.category, category) || other.category == category)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&const DeepCollectionEquality().equals(other._thumbnails, _thumbnails));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,visitedAt,link,category,type,title,subtitle,const DeepCollectionEquality().hash(_thumbnails));

@override
String toString() {
  return 'History(id: $id, visitedAt: $visitedAt, link: $link, category: $category, type: $type, title: $title, subtitle: $subtitle, thumbnails: $thumbnails)';
}


}

/// @nodoc
abstract mixin class _$HistoryCopyWith<$Res> implements $HistoryCopyWith<$Res> {
  factory _$HistoryCopyWith(_History value, $Res Function(_History) _then) = __$HistoryCopyWithImpl;
@override @useResult
$Res call({
 int id, DateTime visitedAt, String link, HistoryCategory category, HistoryType type, String? title, String? subtitle, List<String> thumbnails
});




}
/// @nodoc
class __$HistoryCopyWithImpl<$Res>
    implements _$HistoryCopyWith<$Res> {
  __$HistoryCopyWithImpl(this._self, this._then);

  final _History _self;
  final $Res Function(_History) _then;

/// Create a copy of History
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? visitedAt = null,Object? link = null,Object? category = null,Object? type = null,Object? title = freezed,Object? subtitle = freezed,Object? thumbnails = null,}) {
  return _then(_History(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,visitedAt: null == visitedAt ? _self.visitedAt : visitedAt // ignore: cast_nullable_to_non_nullable
as DateTime,link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as HistoryCategory,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as HistoryType,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,thumbnails: null == thumbnails ? _self._thumbnails : thumbnails // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$HistoryRequest {

 DateTime get visitedAt; String get link; HistoryCategory get category; HistoryType get type; String? get title; String? get subtitle; List<String> get thumbnails;
/// Create a copy of HistoryRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoryRequestCopyWith<HistoryRequest> get copyWith => _$HistoryRequestCopyWithImpl<HistoryRequest>(this as HistoryRequest, _$identity);

  /// Serializes this HistoryRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoryRequest&&(identical(other.visitedAt, visitedAt) || other.visitedAt == visitedAt)&&(identical(other.link, link) || other.link == link)&&(identical(other.category, category) || other.category == category)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&const DeepCollectionEquality().equals(other.thumbnails, thumbnails));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,visitedAt,link,category,type,title,subtitle,const DeepCollectionEquality().hash(thumbnails));

@override
String toString() {
  return 'HistoryRequest(visitedAt: $visitedAt, link: $link, category: $category, type: $type, title: $title, subtitle: $subtitle, thumbnails: $thumbnails)';
}


}

/// @nodoc
abstract mixin class $HistoryRequestCopyWith<$Res>  {
  factory $HistoryRequestCopyWith(HistoryRequest value, $Res Function(HistoryRequest) _then) = _$HistoryRequestCopyWithImpl;
@useResult
$Res call({
 DateTime visitedAt, String link, HistoryCategory category, HistoryType type, String? title, String? subtitle, List<String> thumbnails
});




}
/// @nodoc
class _$HistoryRequestCopyWithImpl<$Res>
    implements $HistoryRequestCopyWith<$Res> {
  _$HistoryRequestCopyWithImpl(this._self, this._then);

  final HistoryRequest _self;
  final $Res Function(HistoryRequest) _then;

/// Create a copy of HistoryRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? visitedAt = null,Object? link = null,Object? category = null,Object? type = null,Object? title = freezed,Object? subtitle = freezed,Object? thumbnails = null,}) {
  return _then(_self.copyWith(
visitedAt: null == visitedAt ? _self.visitedAt : visitedAt // ignore: cast_nullable_to_non_nullable
as DateTime,link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as HistoryCategory,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as HistoryType,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,thumbnails: null == thumbnails ? _self.thumbnails : thumbnails // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _HistoryRequest implements HistoryRequest {
  const _HistoryRequest({required this.visitedAt, required this.link, required this.category, required this.type, this.title, this.subtitle, final  List<String> thumbnails = const []}): _thumbnails = thumbnails;
  factory _HistoryRequest.fromJson(Map<String, dynamic> json) => _$HistoryRequestFromJson(json);

@override final  DateTime visitedAt;
@override final  String link;
@override final  HistoryCategory category;
@override final  HistoryType type;
@override final  String? title;
@override final  String? subtitle;
 final  List<String> _thumbnails;
@override@JsonKey() List<String> get thumbnails {
  if (_thumbnails is EqualUnmodifiableListView) return _thumbnails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_thumbnails);
}


/// Create a copy of HistoryRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistoryRequestCopyWith<_HistoryRequest> get copyWith => __$HistoryRequestCopyWithImpl<_HistoryRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HistoryRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistoryRequest&&(identical(other.visitedAt, visitedAt) || other.visitedAt == visitedAt)&&(identical(other.link, link) || other.link == link)&&(identical(other.category, category) || other.category == category)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&const DeepCollectionEquality().equals(other._thumbnails, _thumbnails));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,visitedAt,link,category,type,title,subtitle,const DeepCollectionEquality().hash(_thumbnails));

@override
String toString() {
  return 'HistoryRequest(visitedAt: $visitedAt, link: $link, category: $category, type: $type, title: $title, subtitle: $subtitle, thumbnails: $thumbnails)';
}


}

/// @nodoc
abstract mixin class _$HistoryRequestCopyWith<$Res> implements $HistoryRequestCopyWith<$Res> {
  factory _$HistoryRequestCopyWith(_HistoryRequest value, $Res Function(_HistoryRequest) _then) = __$HistoryRequestCopyWithImpl;
@override @useResult
$Res call({
 DateTime visitedAt, String link, HistoryCategory category, HistoryType type, String? title, String? subtitle, List<String> thumbnails
});




}
/// @nodoc
class __$HistoryRequestCopyWithImpl<$Res>
    implements _$HistoryRequestCopyWith<$Res> {
  __$HistoryRequestCopyWithImpl(this._self, this._then);

  final _HistoryRequest _self;
  final $Res Function(_HistoryRequest) _then;

/// Create a copy of HistoryRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? visitedAt = null,Object? link = null,Object? category = null,Object? type = null,Object? title = freezed,Object? subtitle = freezed,Object? thumbnails = null,}) {
  return _then(_HistoryRequest(
visitedAt: null == visitedAt ? _self.visitedAt : visitedAt // ignore: cast_nullable_to_non_nullable
as DateTime,link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as HistoryCategory,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as HistoryType,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,thumbnails: null == thumbnails ? _self._thumbnails : thumbnails // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
