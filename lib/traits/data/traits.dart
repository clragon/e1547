import 'package:freezed_annotation/freezed_annotation.dart';

part 'traits.freezed.dart';
part 'traits.g.dart';

@freezed
abstract class Traits with _$Traits {
  const factory Traits({
    required int id,
    required int? userId,
    required List<String> denylist,
    required String homeTags,
    required String? avatar,
    required int? perPage,
  }) = _Traits;

  factory Traits.fromJson(Map<String, dynamic> json) => _$TraitsFromJson(json);
}

@freezed
abstract class TraitsRequest with _$TraitsRequest {
  const factory TraitsRequest({
    required int identity,
    int? userId,
    @Default([]) List<String> denylist,
    @Default('') String homeTags,
    String? avatar,
    int? perPage,
  }) = _TraitsRequest;

  factory TraitsRequest.fromJson(Map<String, dynamic> json) =>
      _$TraitsRequestFromJson(json);
}
