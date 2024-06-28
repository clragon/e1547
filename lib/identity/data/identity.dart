import 'package:e1547/client/client.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'identity.freezed.dart';
part 'identity.g.dart';

@freezed
class Identity with _$Identity {
  const factory Identity({
    required int id,
    required String host,
    required ClientType type,
    required String? username,
    required Map<String, String>? headers,
  }) = _Identity;

  factory Identity.fromJson(dynamic json) => _$IdentityFromJson(json);
}

@freezed
class IdentityRequest with _$IdentityRequest {
  const factory IdentityRequest({
    required String host,
    required ClientType type,
    String? username,
    Map<String, String>? headers,
  }) = _IdentityRequest;

  factory IdentityRequest.fromJson(dynamic json) =>
      _$IdentityRequestFromJson(json);
}
