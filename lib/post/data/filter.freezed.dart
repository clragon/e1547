// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostFilterValue implements DiagnosticableTreeMixin {

 bool get denying; List<String> get allowedEntries; List<int> get allowedPosts;
/// Create a copy of PostFilterValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostFilterValueCopyWith<PostFilterValue> get copyWith => _$PostFilterValueCopyWithImpl<PostFilterValue>(this as PostFilterValue, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'PostFilterValue'))
    ..add(DiagnosticsProperty('denying', denying))..add(DiagnosticsProperty('allowedEntries', allowedEntries))..add(DiagnosticsProperty('allowedPosts', allowedPosts));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostFilterValue&&(identical(other.denying, denying) || other.denying == denying)&&const DeepCollectionEquality().equals(other.allowedEntries, allowedEntries)&&const DeepCollectionEquality().equals(other.allowedPosts, allowedPosts));
}


@override
int get hashCode => Object.hash(runtimeType,denying,const DeepCollectionEquality().hash(allowedEntries),const DeepCollectionEquality().hash(allowedPosts));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'PostFilterValue(denying: $denying, allowedEntries: $allowedEntries, allowedPosts: $allowedPosts)';
}


}

/// @nodoc
abstract mixin class $PostFilterValueCopyWith<$Res>  {
  factory $PostFilterValueCopyWith(PostFilterValue value, $Res Function(PostFilterValue) _then) = _$PostFilterValueCopyWithImpl;
@useResult
$Res call({
 bool denying, List<String> allowedEntries, List<int> allowedPosts
});




}
/// @nodoc
class _$PostFilterValueCopyWithImpl<$Res>
    implements $PostFilterValueCopyWith<$Res> {
  _$PostFilterValueCopyWithImpl(this._self, this._then);

  final PostFilterValue _self;
  final $Res Function(PostFilterValue) _then;

/// Create a copy of PostFilterValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? denying = null,Object? allowedEntries = null,Object? allowedPosts = null,}) {
  return _then(_self.copyWith(
denying: null == denying ? _self.denying : denying // ignore: cast_nullable_to_non_nullable
as bool,allowedEntries: null == allowedEntries ? _self.allowedEntries : allowedEntries // ignore: cast_nullable_to_non_nullable
as List<String>,allowedPosts: null == allowedPosts ? _self.allowedPosts : allowedPosts // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// @nodoc


class _PostFilterValue with DiagnosticableTreeMixin implements PostFilterValue {
  const _PostFilterValue({this.denying = true, final  List<String> allowedEntries = const [], final  List<int> allowedPosts = const []}): _allowedEntries = allowedEntries,_allowedPosts = allowedPosts;
  

@override@JsonKey() final  bool denying;
 final  List<String> _allowedEntries;
@override@JsonKey() List<String> get allowedEntries {
  if (_allowedEntries is EqualUnmodifiableListView) return _allowedEntries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedEntries);
}

 final  List<int> _allowedPosts;
@override@JsonKey() List<int> get allowedPosts {
  if (_allowedPosts is EqualUnmodifiableListView) return _allowedPosts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allowedPosts);
}


/// Create a copy of PostFilterValue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostFilterValueCopyWith<_PostFilterValue> get copyWith => __$PostFilterValueCopyWithImpl<_PostFilterValue>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'PostFilterValue'))
    ..add(DiagnosticsProperty('denying', denying))..add(DiagnosticsProperty('allowedEntries', allowedEntries))..add(DiagnosticsProperty('allowedPosts', allowedPosts));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostFilterValue&&(identical(other.denying, denying) || other.denying == denying)&&const DeepCollectionEquality().equals(other._allowedEntries, _allowedEntries)&&const DeepCollectionEquality().equals(other._allowedPosts, _allowedPosts));
}


@override
int get hashCode => Object.hash(runtimeType,denying,const DeepCollectionEquality().hash(_allowedEntries),const DeepCollectionEquality().hash(_allowedPosts));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'PostFilterValue(denying: $denying, allowedEntries: $allowedEntries, allowedPosts: $allowedPosts)';
}


}

/// @nodoc
abstract mixin class _$PostFilterValueCopyWith<$Res> implements $PostFilterValueCopyWith<$Res> {
  factory _$PostFilterValueCopyWith(_PostFilterValue value, $Res Function(_PostFilterValue) _then) = __$PostFilterValueCopyWithImpl;
@override @useResult
$Res call({
 bool denying, List<String> allowedEntries, List<int> allowedPosts
});




}
/// @nodoc
class __$PostFilterValueCopyWithImpl<$Res>
    implements _$PostFilterValueCopyWith<$Res> {
  __$PostFilterValueCopyWithImpl(this._self, this._then);

  final _PostFilterValue _self;
  final $Res Function(_PostFilterValue) _then;

/// Create a copy of PostFilterValue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? denying = null,Object? allowedEntries = null,Object? allowedPosts = null,}) {
  return _then(_PostFilterValue(
denying: null == denying ? _self.denying : denying // ignore: cast_nullable_to_non_nullable
as bool,allowedEntries: null == allowedEntries ? _self._allowedEntries : allowedEntries // ignore: cast_nullable_to_non_nullable
as List<String>,allowedPosts: null == allowedPosts ? _self._allowedPosts : allowedPosts // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}

// dart format on
