// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Donor _$DonorFromJson(Map<String, dynamic> json) => _Donor(
  name: json['name'] as String,
  avatar: json['avatar'] as String?,
  handles: Map<String, String>.from(json['handles'] as Map),
  donations: (json['donations'] as List<dynamic>)
      .map((e) => Donation.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DonorToJson(_Donor instance) => <String, dynamic>{
  'name': instance.name,
  'avatar': instance.avatar,
  'handles': instance.handles,
  'donations': instance.donations,
};

_Donation _$DonationFromJson(Map<String, dynamic> json) => _Donation(
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String,
  date: DateTime.parse(json['date'] as String),
  platform: json['platform'] as String,
);

Map<String, dynamic> _$DonationToJson(_Donation instance) => <String, dynamic>{
  'amount': instance.amount,
  'currency': instance.currency,
  'date': instance.date.toIso8601String(),
  'platform': instance.platform,
};
