import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
@CopyWith()
class User {
  User({
    required this.wikiPageVersionCount,
    required this.artistVersionCount,
    required this.poolVersionCount,
    required this.forumPostCount,
    required this.commentCount,
    required this.flagCount,
    required this.positiveFeedbackCount,
    required this.neutralFeedbackCount,
    required this.negativeFeedbackCount,
    required this.uploadLimit,
    required this.id,
    required this.createdAt,
    required this.name,
    required this.level,
    required this.baseUploadLimit,
    required this.postUploadCount,
    required this.postUpdateCount,
    required this.noteUpdateCount,
    required this.isBanned,
    required this.canApprovePosts,
    required this.canUploadFree,
    required this.levelString,
    required this.avatarId,
  });

  final int wikiPageVersionCount;
  final int artistVersionCount;
  final int poolVersionCount;
  final int forumPostCount;
  final int commentCount;
  final int flagCount;
  final int positiveFeedbackCount;
  final int neutralFeedbackCount;
  final int negativeFeedbackCount;
  final int uploadLimit;
  final int id;
  final DateTime createdAt;
  final String name;
  final int level;
  final int baseUploadLimit;
  final int postUploadCount;
  final int postUpdateCount;
  final int noteUpdateCount;
  final bool isBanned;
  final bool canApprovePosts;
  final bool canUploadFree;
  final String levelString;
  final int? avatarId;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
