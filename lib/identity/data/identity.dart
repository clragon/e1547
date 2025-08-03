import 'package:freezed_annotation/freezed_annotation.dart';

part 'identity.freezed.dart';
part 'identity.g.dart';

@freezed
abstract class Identity with _$Identity {
  const factory Identity({
    required int id,
    required String host,
    required String? username,
    required Map<String, String>? headers,
  }) = _Identity;

  factory Identity.fromJson(dynamic json) => _$IdentityFromJson(json);
}

@freezed
abstract class IdentityRequest with _$IdentityRequest {
  const factory IdentityRequest({
    required String host,
    String? username,
    Map<String, String>? headers,
  }) = _IdentityRequest;

  factory IdentityRequest.fromJson(dynamic json) =>
      _$IdentityRequestFromJson(json);
}
