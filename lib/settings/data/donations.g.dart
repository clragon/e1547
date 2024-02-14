// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DonorImpl _$$DonorImplFromJson(Map<String, dynamic> json) => _$DonorImpl(
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      handles: Map<String, String>.from(json['handles'] as Map),
      donations: (json['donations'] as List<dynamic>)
          .map((e) => Donation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$DonorImplToJson(_$DonorImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'avatar': instance.avatar,
      'handles': instance.handles,
      'donations': instance.donations,
    };

_$DonationImpl _$$DonationImplFromJson(Map<String, dynamic> json) =>
    _$DonationImpl(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      date: DateTime.parse(json['date'] as String),
      platform: json['platform'] as String,
    );

Map<String, dynamic> _$$DonationImplToJson(_$DonationImpl instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'currency': instance.currency,
      'date': instance.date.toIso8601String(),
      'platform': instance.platform,
    };
