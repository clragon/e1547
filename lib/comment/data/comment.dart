import 'package:e1547/interface/interface.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

@freezed
class Comment with _$Comment {
  const factory Comment({
    required int id,
    required DateTime createdAt,
    required int postId,
    required int creatorId,
    required String body,
    required int score,
    required DateTime updatedAt,
    required int updaterId,
    required bool doNotBumpPost,
    required bool isHidden,
    required bool isSticky,
    required int? warningType,
    required int? warningUserId,
    required String creatorName,
    required String updaterName,
    @JsonKey(ignore: true) @Default(VoteStatus.unknown) VoteStatus voteStatus,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
}
