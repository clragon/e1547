import 'package:e1547/interface/interface.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

@freezed
class Comment with _$Comment {
  const factory Comment({
    required int id,
    required int postId,
    required String body,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int creatorId,
    required String creatorName,
    required VoteInfo? vote,
    required WarningType? warning,
  }) = _Comment;

  factory Comment.fromJson(dynamic json) => _$CommentFromJson(json);
}

@JsonEnum()
enum WarningType {
  warning,
  record,
  ban;

  String get message {
    switch (this) {
      case warning:
        return 'User received a warning for this message';
      case record:
        return 'User received a record for this message';
      case ban:
        return 'User was banned for this message';
    }
  }
}
