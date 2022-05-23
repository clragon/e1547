import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:e1547/interface/interface.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comment.g.dart';

@JsonSerializable()
@CopyWith()
class Comment {
  @JsonKey(ignore: true)
  final VoteStatus voteStatus;

  const Comment({
    required this.id,
    required this.createdAt,
    required this.postId,
    required this.creatorId,
    required this.body,
    required this.score,
    required this.updatedAt,
    required this.updaterId,
    required this.doNotBumpPost,
    required this.isHidden,
    required this.isSticky,
    this.warningType,
    this.warningUserId,
    required this.creatorName,
    required this.updaterName,
    this.voteStatus = VoteStatus.unknown,
  });

  final int id;
  final DateTime createdAt;
  final int postId;
  final int creatorId;
  final String body;
  final int score;
  final DateTime updatedAt;
  final int updaterId;
  final bool doNotBumpPost;
  final bool isHidden;
  final bool isSticky;
  final int? warningType;
  final int? warningUserId;
  final String creatorName;
  final String updaterName;

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
