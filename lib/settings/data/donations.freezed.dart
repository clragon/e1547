// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'donations.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Donor _$DonorFromJson(Map<String, dynamic> json) {
  return _Donor.fromJson(json);
}

/// @nodoc
mixin _$Donor {
  String get name => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;
  Map<String, String> get handles => throw _privateConstructorUsedError;
  List<Donation> get donations => throw _privateConstructorUsedError;

  /// Serializes this Donor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Donor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DonorCopyWith<Donor> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DonorCopyWith<$Res> {
  factory $DonorCopyWith(Donor value, $Res Function(Donor) then) =
      _$DonorCopyWithImpl<$Res, Donor>;
  @useResult
  $Res call({
    String name,
    String? avatar,
    Map<String, String> handles,
    List<Donation> donations,
  });
}

/// @nodoc
class _$DonorCopyWithImpl<$Res, $Val extends Donor>
    implements $DonorCopyWith<$Res> {
  _$DonorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Donor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? avatar = freezed,
    Object? handles = null,
    Object? donations = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            avatar: freezed == avatar
                ? _value.avatar
                : avatar // ignore: cast_nullable_to_non_nullable
                      as String?,
            handles: null == handles
                ? _value.handles
                : handles // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            donations: null == donations
                ? _value.donations
                : donations // ignore: cast_nullable_to_non_nullable
                      as List<Donation>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DonorImplCopyWith<$Res> implements $DonorCopyWith<$Res> {
  factory _$$DonorImplCopyWith(
    _$DonorImpl value,
    $Res Function(_$DonorImpl) then,
  ) = __$$DonorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String? avatar,
    Map<String, String> handles,
    List<Donation> donations,
  });
}

/// @nodoc
class __$$DonorImplCopyWithImpl<$Res>
    extends _$DonorCopyWithImpl<$Res, _$DonorImpl>
    implements _$$DonorImplCopyWith<$Res> {
  __$$DonorImplCopyWithImpl(
    _$DonorImpl _value,
    $Res Function(_$DonorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Donor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? avatar = freezed,
    Object? handles = null,
    Object? donations = null,
  }) {
    return _then(
      _$DonorImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        avatar: freezed == avatar
            ? _value.avatar
            : avatar // ignore: cast_nullable_to_non_nullable
                  as String?,
        handles: null == handles
            ? _value._handles
            : handles // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        donations: null == donations
            ? _value._donations
            : donations // ignore: cast_nullable_to_non_nullable
                  as List<Donation>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DonorImpl implements _Donor {
  const _$DonorImpl({
    required this.name,
    this.avatar,
    required final Map<String, String> handles,
    required final List<Donation> donations,
  }) : _handles = handles,
       _donations = donations;

  factory _$DonorImpl.fromJson(Map<String, dynamic> json) =>
      _$$DonorImplFromJson(json);

  @override
  final String name;
  @override
  final String? avatar;
  final Map<String, String> _handles;
  @override
  Map<String, String> get handles {
    if (_handles is EqualUnmodifiableMapView) return _handles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_handles);
  }

  final List<Donation> _donations;
  @override
  List<Donation> get donations {
    if (_donations is EqualUnmodifiableListView) return _donations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_donations);
  }

  @override
  String toString() {
    return 'Donor(name: $name, avatar: $avatar, handles: $handles, donations: $donations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DonorImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            const DeepCollectionEquality().equals(other._handles, _handles) &&
            const DeepCollectionEquality().equals(
              other._donations,
              _donations,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    avatar,
    const DeepCollectionEquality().hash(_handles),
    const DeepCollectionEquality().hash(_donations),
  );

  /// Create a copy of Donor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DonorImplCopyWith<_$DonorImpl> get copyWith =>
      __$$DonorImplCopyWithImpl<_$DonorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DonorImplToJson(this);
  }
}

abstract class _Donor implements Donor {
  const factory _Donor({
    required final String name,
    final String? avatar,
    required final Map<String, String> handles,
    required final List<Donation> donations,
  }) = _$DonorImpl;

  factory _Donor.fromJson(Map<String, dynamic> json) = _$DonorImpl.fromJson;

  @override
  String get name;
  @override
  String? get avatar;
  @override
  Map<String, String> get handles;
  @override
  List<Donation> get donations;

  /// Create a copy of Donor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DonorImplCopyWith<_$DonorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Donation _$DonationFromJson(Map<String, dynamic> json) {
  return _Donation.fromJson(json);
}

/// @nodoc
mixin _$Donation {
  double get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get platform => throw _privateConstructorUsedError;

  /// Serializes this Donation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Donation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DonationCopyWith<Donation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DonationCopyWith<$Res> {
  factory $DonationCopyWith(Donation value, $Res Function(Donation) then) =
      _$DonationCopyWithImpl<$Res, Donation>;
  @useResult
  $Res call({double amount, String currency, DateTime date, String platform});
}

/// @nodoc
class _$DonationCopyWithImpl<$Res, $Val extends Donation>
    implements $DonationCopyWith<$Res> {
  _$DonationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Donation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = null,
    Object? currency = null,
    Object? date = null,
    Object? platform = null,
  }) {
    return _then(
      _value.copyWith(
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            platform: null == platform
                ? _value.platform
                : platform // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DonationImplCopyWith<$Res>
    implements $DonationCopyWith<$Res> {
  factory _$$DonationImplCopyWith(
    _$DonationImpl value,
    $Res Function(_$DonationImpl) then,
  ) = __$$DonationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double amount, String currency, DateTime date, String platform});
}

/// @nodoc
class __$$DonationImplCopyWithImpl<$Res>
    extends _$DonationCopyWithImpl<$Res, _$DonationImpl>
    implements _$$DonationImplCopyWith<$Res> {
  __$$DonationImplCopyWithImpl(
    _$DonationImpl _value,
    $Res Function(_$DonationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Donation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amount = null,
    Object? currency = null,
    Object? date = null,
    Object? platform = null,
  }) {
    return _then(
      _$DonationImpl(
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        platform: null == platform
            ? _value.platform
            : platform // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DonationImpl implements _Donation {
  const _$DonationImpl({
    required this.amount,
    required this.currency,
    required this.date,
    required this.platform,
  });

  factory _$DonationImpl.fromJson(Map<String, dynamic> json) =>
      _$$DonationImplFromJson(json);

  @override
  final double amount;
  @override
  final String currency;
  @override
  final DateTime date;
  @override
  final String platform;

  @override
  String toString() {
    return 'Donation(amount: $amount, currency: $currency, date: $date, platform: $platform)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DonationImpl &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.platform, platform) ||
                other.platform == platform));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, amount, currency, date, platform);

  /// Create a copy of Donation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DonationImplCopyWith<_$DonationImpl> get copyWith =>
      __$$DonationImplCopyWithImpl<_$DonationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DonationImplToJson(this);
  }
}

abstract class _Donation implements Donation {
  const factory _Donation({
    required final double amount,
    required final String currency,
    required final DateTime date,
    required final String platform,
  }) = _$DonationImpl;

  factory _Donation.fromJson(Map<String, dynamic> json) =
      _$DonationImpl.fromJson;

  @override
  double get amount;
  @override
  String get currency;
  @override
  DateTime get date;
  @override
  String get platform;

  /// Create a copy of Donation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DonationImplCopyWith<_$DonationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
