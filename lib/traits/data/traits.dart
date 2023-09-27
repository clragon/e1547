import 'package:freezed_annotation/freezed_annotation.dart';

part 'traits.freezed.dart';
part 'traits.g.dart';

@freezed
class Traits with _$Traits {
  const factory Traits({
    required int id,
    required List<String> denylist,
    required String homeTags,
  }) = _Traits;

  factory Traits.fromJson(Map<String, dynamic> json) => _$TraitsFromJson(json);
}

@freezed
class TraitsRequest with _$TraitsRequest {
  const factory TraitsRequest({
    required int identity,
    @Default([]) List<String> denylist,
    @Default('') String homeTags,
  }) = _TraitsRequest;

  factory TraitsRequest.fromJson(Map<String, dynamic> json) =>
      _$TraitsRequestFromJson(json);
}
