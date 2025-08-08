import 'package:freezed_annotation/freezed_annotation.dart';

part 'donations.freezed.dart';
part 'donations.g.dart';

@freezed
abstract class Donor with _$Donor {
  const factory Donor({
    required String name,
    String? avatar,
    required Map<String, String> handles,
    required List<Donation> donations,
  }) = _Donor;

  factory Donor.fromJson(Map<String, dynamic> json) => _$DonorFromJson(json);
}

@freezed
abstract class Donation with _$Donation {
  const factory Donation({
    required double amount,
    required String currency,
    required DateTime date,
    required String platform,
  }) = _Donation;

  factory Donation.fromJson(Map<String, dynamic> json) =>
      _$DonationFromJson(json);
}
