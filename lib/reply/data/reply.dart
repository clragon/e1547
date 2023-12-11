import 'package:deep_pick/deep_pick.dart';
import 'package:e1547/comment/comment.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'reply.freezed.dart';
part 'reply.g.dart';

@freezed
class Reply with _$Reply {
  const factory Reply({
    required int id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String body,
    required int creatorId,
    required int topicId,
    required ReplyWarning? warning,
  }) = _Reply;

  factory Reply.fromJson(Map<String, dynamic> json) => _$ReplyFromJson(json);
}

@freezed
class ReplyWarning with _$ReplyWarning {
  const factory ReplyWarning({
    required WarningType? type,
  }) = _ReplyWarning;

  factory ReplyWarning.fromJson(Map<String, dynamic> json) =>
      _$ReplyWarningFromJson(json);
}

extension E621Reply on Reply {
  static Reply fromJson(dynamic json) => pick(json).letOrThrow(
        (pick) => Reply(
          id: pick('id').asIntOrThrow(),
          createdAt: pick('created_at').asDateTimeOrThrow(),
          updatedAt: pick('updated_at').asDateTimeOrThrow(),
          body: pick('body').asStringOrThrow(),
          creatorId: pick('creator_id').asIntOrThrow(),
          topicId: pick('topic_id').asIntOrThrow(),
          warning: ReplyWarning(
            type: pick('warning_type').letOrNull(
                (pick) => WarningType.values.asNameMap()[pick.asString()]!),
          ),
        ),
      );
}
