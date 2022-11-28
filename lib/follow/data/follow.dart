import 'package:freezed_annotation/freezed_annotation.dart';

part 'follow.freezed.dart';
part 'follow.g.dart';

@freezed
class Follow with _$Follow {
  const factory Follow({
    required int id,
    required String tags,
    required String? title,
    required String? alias,
    required FollowType type,
    required int? latest,
    required int? unseen,
    required String? thumbnail,
    required DateTime? updated,
  }) = _Follow;

  factory Follow.fromJson(dynamic json) => _$FollowFromJson(json);
}

@freezed
class FollowRequest with _$FollowRequest {
  const factory FollowRequest({
    required String tags,
    String? title,
    String? alias,
    @Default(FollowType.update) FollowType type,
  }) = _FollowRequest;

  factory FollowRequest.fromJson(Map<String, dynamic> json) =>
      _$FollowRequestFromJson(json);
}

@JsonEnum()
enum FollowType {
  update,
  notify,
  bookmark,
}
