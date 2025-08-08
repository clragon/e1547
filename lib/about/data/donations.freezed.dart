// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'donations.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Donor {

 String get name; String? get avatar; Map<String, String> get handles; List<Donation> get donations;
/// Create a copy of Donor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DonorCopyWith<Donor> get copyWith => _$DonorCopyWithImpl<Donor>(this as Donor, _$identity);

  /// Serializes this Donor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Donor&&(identical(other.name, name) || other.name == name)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&const DeepCollectionEquality().equals(other.handles, handles)&&const DeepCollectionEquality().equals(other.donations, donations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,avatar,const DeepCollectionEquality().hash(handles),const DeepCollectionEquality().hash(donations));

@override
String toString() {
  return 'Donor(name: $name, avatar: $avatar, handles: $handles, donations: $donations)';
}


}

/// @nodoc
abstract mixin class $DonorCopyWith<$Res>  {
  factory $DonorCopyWith(Donor value, $Res Function(Donor) _then) = _$DonorCopyWithImpl;
@useResult
$Res call({
 String name, String? avatar, Map<String, String> handles, List<Donation> donations
});




}
/// @nodoc
class _$DonorCopyWithImpl<$Res>
    implements $DonorCopyWith<$Res> {
  _$DonorCopyWithImpl(this._self, this._then);

  final Donor _self;
  final $Res Function(Donor) _then;

/// Create a copy of Donor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? avatar = freezed,Object? handles = null,Object? donations = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,handles: null == handles ? _self.handles : handles // ignore: cast_nullable_to_non_nullable
as Map<String, String>,donations: null == donations ? _self.donations : donations // ignore: cast_nullable_to_non_nullable
as List<Donation>,
  ));
}

}



/// @nodoc
@JsonSerializable()

class _Donor implements Donor {
  const _Donor({required this.name, this.avatar, required final  Map<String, String> handles, required final  List<Donation> donations}): _handles = handles,_donations = donations;
  factory _Donor.fromJson(Map<String, dynamic> json) => _$DonorFromJson(json);

@override final  String name;
@override final  String? avatar;
 final  Map<String, String> _handles;
@override Map<String, String> get handles {
  if (_handles is EqualUnmodifiableMapView) return _handles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_handles);
}

 final  List<Donation> _donations;
@override List<Donation> get donations {
  if (_donations is EqualUnmodifiableListView) return _donations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_donations);
}


/// Create a copy of Donor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DonorCopyWith<_Donor> get copyWith => __$DonorCopyWithImpl<_Donor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DonorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Donor&&(identical(other.name, name) || other.name == name)&&(identical(other.avatar, avatar) || other.avatar == avatar)&&const DeepCollectionEquality().equals(other._handles, _handles)&&const DeepCollectionEquality().equals(other._donations, _donations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,avatar,const DeepCollectionEquality().hash(_handles),const DeepCollectionEquality().hash(_donations));

@override
String toString() {
  return 'Donor(name: $name, avatar: $avatar, handles: $handles, donations: $donations)';
}


}

/// @nodoc
abstract mixin class _$DonorCopyWith<$Res> implements $DonorCopyWith<$Res> {
  factory _$DonorCopyWith(_Donor value, $Res Function(_Donor) _then) = __$DonorCopyWithImpl;
@override @useResult
$Res call({
 String name, String? avatar, Map<String, String> handles, List<Donation> donations
});




}
/// @nodoc
class __$DonorCopyWithImpl<$Res>
    implements _$DonorCopyWith<$Res> {
  __$DonorCopyWithImpl(this._self, this._then);

  final _Donor _self;
  final $Res Function(_Donor) _then;

/// Create a copy of Donor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? avatar = freezed,Object? handles = null,Object? donations = null,}) {
  return _then(_Donor(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatar: freezed == avatar ? _self.avatar : avatar // ignore: cast_nullable_to_non_nullable
as String?,handles: null == handles ? _self._handles : handles // ignore: cast_nullable_to_non_nullable
as Map<String, String>,donations: null == donations ? _self._donations : donations // ignore: cast_nullable_to_non_nullable
as List<Donation>,
  ));
}


}


/// @nodoc
mixin _$Donation {

 double get amount; String get currency; DateTime get date; String get platform;
/// Create a copy of Donation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DonationCopyWith<Donation> get copyWith => _$DonationCopyWithImpl<Donation>(this as Donation, _$identity);

  /// Serializes this Donation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Donation&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.date, date) || other.date == date)&&(identical(other.platform, platform) || other.platform == platform));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,currency,date,platform);

@override
String toString() {
  return 'Donation(amount: $amount, currency: $currency, date: $date, platform: $platform)';
}


}

/// @nodoc
abstract mixin class $DonationCopyWith<$Res>  {
  factory $DonationCopyWith(Donation value, $Res Function(Donation) _then) = _$DonationCopyWithImpl;
@useResult
$Res call({
 double amount, String currency, DateTime date, String platform
});




}
/// @nodoc
class _$DonationCopyWithImpl<$Res>
    implements $DonationCopyWith<$Res> {
  _$DonationCopyWithImpl(this._self, this._then);

  final Donation _self;
  final $Res Function(Donation) _then;

/// Create a copy of Donation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? amount = null,Object? currency = null,Object? date = null,Object? platform = null,}) {
  return _then(_self.copyWith(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}



/// @nodoc
@JsonSerializable()

class _Donation implements Donation {
  const _Donation({required this.amount, required this.currency, required this.date, required this.platform});
  factory _Donation.fromJson(Map<String, dynamic> json) => _$DonationFromJson(json);

@override final  double amount;
@override final  String currency;
@override final  DateTime date;
@override final  String platform;

/// Create a copy of Donation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DonationCopyWith<_Donation> get copyWith => __$DonationCopyWithImpl<_Donation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DonationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Donation&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.date, date) || other.date == date)&&(identical(other.platform, platform) || other.platform == platform));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,amount,currency,date,platform);

@override
String toString() {
  return 'Donation(amount: $amount, currency: $currency, date: $date, platform: $platform)';
}


}

/// @nodoc
abstract mixin class _$DonationCopyWith<$Res> implements $DonationCopyWith<$Res> {
  factory _$DonationCopyWith(_Donation value, $Res Function(_Donation) _then) = __$DonationCopyWithImpl;
@override @useResult
$Res call({
 double amount, String currency, DateTime date, String platform
});




}
/// @nodoc
class __$DonationCopyWithImpl<$Res>
    implements _$DonationCopyWith<$Res> {
  __$DonationCopyWithImpl(this._self, this._then);

  final _Donation _self;
  final $Res Function(_Donation) _then;

/// Create a copy of Donation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? amount = null,Object? currency = null,Object? date = null,Object? platform = null,}) {
  return _then(_Donation(
amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,platform: null == platform ? _self.platform : platform // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
