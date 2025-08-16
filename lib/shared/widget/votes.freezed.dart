// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'votes.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoteInfo {

 int get score; VoteStatus get status;
/// Create a copy of VoteInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoteInfoCopyWith<VoteInfo> get copyWith => _$VoteInfoCopyWithImpl<VoteInfo>(this as VoteInfo, _$identity);

  /// Serializes this VoteInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoteInfo&&(identical(other.score, score) || other.score == score)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,score,status);

@override
String toString() {
  return 'VoteInfo(score: $score, status: $status)';
}


}

/// @nodoc
abstract mixin class $VoteInfoCopyWith<$Res>  {
  factory $VoteInfoCopyWith(VoteInfo value, $Res Function(VoteInfo) _then) = _$VoteInfoCopyWithImpl;
@useResult
$Res call({
 int score, VoteStatus status
});




}
/// @nodoc
class _$VoteInfoCopyWithImpl<$Res>
    implements $VoteInfoCopyWith<$Res> {
  _$VoteInfoCopyWithImpl(this._self, this._then);

  final VoteInfo _self;
  final $Res Function(VoteInfo) _then;

/// Create a copy of VoteInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? score = null,Object? status = null,}) {
  return _then(_self.copyWith(
score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VoteStatus,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _VoteInfo extends VoteInfo {
  const _VoteInfo({required this.score, this.status = VoteStatus.unknown}): super._();
  factory _VoteInfo.fromJson(Map<String, dynamic> json) => _$VoteInfoFromJson(json);

@override final  int score;
@override@JsonKey() final  VoteStatus status;

/// Create a copy of VoteInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoteInfoCopyWith<_VoteInfo> get copyWith => __$VoteInfoCopyWithImpl<_VoteInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoteInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoteInfo&&(identical(other.score, score) || other.score == score)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,score,status);

@override
String toString() {
  return 'VoteInfo(score: $score, status: $status)';
}


}

/// @nodoc
abstract mixin class _$VoteInfoCopyWith<$Res> implements $VoteInfoCopyWith<$Res> {
  factory _$VoteInfoCopyWith(_VoteInfo value, $Res Function(_VoteInfo) _then) = __$VoteInfoCopyWithImpl;
@override @useResult
$Res call({
 int score, VoteStatus status
});




}
/// @nodoc
class __$VoteInfoCopyWithImpl<$Res>
    implements _$VoteInfoCopyWith<$Res> {
  __$VoteInfoCopyWithImpl(this._self, this._then);

  final _VoteInfo _self;
  final $Res Function(_VoteInfo) _then;

/// Create a copy of VoteInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? score = null,Object? status = null,}) {
  return _then(_VoteInfo(
score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as VoteStatus,
  ));
}


}


/// @nodoc
mixin _$VoteResult {

 int get score; int get ourScore;
/// Create a copy of VoteResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoteResultCopyWith<VoteResult> get copyWith => _$VoteResultCopyWithImpl<VoteResult>(this as VoteResult, _$identity);

  /// Serializes this VoteResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoteResult&&(identical(other.score, score) || other.score == score)&&(identical(other.ourScore, ourScore) || other.ourScore == ourScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,score,ourScore);

@override
String toString() {
  return 'VoteResult(score: $score, ourScore: $ourScore)';
}


}

/// @nodoc
abstract mixin class $VoteResultCopyWith<$Res>  {
  factory $VoteResultCopyWith(VoteResult value, $Res Function(VoteResult) _then) = _$VoteResultCopyWithImpl;
@useResult
$Res call({
 int score, int ourScore
});




}
/// @nodoc
class _$VoteResultCopyWithImpl<$Res>
    implements $VoteResultCopyWith<$Res> {
  _$VoteResultCopyWithImpl(this._self, this._then);

  final VoteResult _self;
  final $Res Function(VoteResult) _then;

/// Create a copy of VoteResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? score = null,Object? ourScore = null,}) {
  return _then(_self.copyWith(
score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,ourScore: null == ourScore ? _self.ourScore : ourScore // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// @nodoc
@JsonSerializable()

class _VoteResult implements VoteResult {
  const _VoteResult({required this.score, required this.ourScore});
  factory _VoteResult.fromJson(Map<String, dynamic> json) => _$VoteResultFromJson(json);

@override final  int score;
@override final  int ourScore;

/// Create a copy of VoteResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoteResultCopyWith<_VoteResult> get copyWith => __$VoteResultCopyWithImpl<_VoteResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoteResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoteResult&&(identical(other.score, score) || other.score == score)&&(identical(other.ourScore, ourScore) || other.ourScore == ourScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,score,ourScore);

@override
String toString() {
  return 'VoteResult(score: $score, ourScore: $ourScore)';
}


}

/// @nodoc
abstract mixin class _$VoteResultCopyWith<$Res> implements $VoteResultCopyWith<$Res> {
  factory _$VoteResultCopyWith(_VoteResult value, $Res Function(_VoteResult) _then) = __$VoteResultCopyWithImpl;
@override @useResult
$Res call({
 int score, int ourScore
});




}
/// @nodoc
class __$VoteResultCopyWithImpl<$Res>
    implements _$VoteResultCopyWith<$Res> {
  __$VoteResultCopyWithImpl(this._self, this._then);

  final _VoteResult _self;
  final $Res Function(_VoteResult) _then;

/// Create a copy of VoteResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? score = null,Object? ourScore = null,}) {
  return _then(_VoteResult(
score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as int,ourScore: null == ourScore ? _self.ourScore : ourScore // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
