import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'follow.freezed.dart';
part 'follow.g.dart';

@freezed
class Follow with _$Follow {
  const factory Follow({
    required String tags,
    String? alias,
    @Default(FollowType.update) FollowType type,
    @Default({}) Map<String, FollowStatus> statuses,
  }) = _Follow;

  factory Follow.fromJson(Map<String, dynamic> json) => _$FollowFromJson(json);
}

@freezed
class FollowStatus with _$FollowStatus {
  const factory FollowStatus({
    int? latest,
    int? unseen,
    String? thumbnail,
    DateTime? updated,
  }) = _FollowStatus;

  factory FollowStatus.fromJson(Map<String, dynamic> json) =>
      _$FollowStatusFromJson(json);
}

@JsonEnum()
enum FollowType {
  update,
  notify,
  bookmark,
}
