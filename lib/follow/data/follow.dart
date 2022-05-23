import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'follow.g.dart';

@JsonSerializable()
@CopyWith()
class Follow {
  final String tags;
  final String? alias;
  final FollowType type;
  final Map<String, FollowStatus> statuses;

  Follow({
    required this.tags,
    this.alias,
    this.type = FollowType.update,
    this.statuses = const {},
  });

  factory Follow.fromJson(Map<String, dynamic> json) => _$FollowFromJson(json);

  Map<String, dynamic> toJson() => _$FollowToJson(this);
}

@JsonSerializable()
@CopyWith()
class FollowStatus {
  final int? latest;
  final int? unseen;
  final String? thumbnail;
  final DateTime? updated;

  FollowStatus({
    this.latest,
    this.unseen,
    this.thumbnail,
    this.updated,
  });

  factory FollowStatus.fromJson(Map<String, dynamic> json) =>
      _$FollowStatusFromJson(json);

  Map<String, dynamic> toJson() => _$FollowStatusToJson(this);
}

@JsonEnum()
enum FollowType {
  update,
  notify,
  bookmark,
}
