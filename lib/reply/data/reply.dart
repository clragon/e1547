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
    required WarningType? warning,
    required bool hidden,
  }) = _Reply;

  factory Reply.fromJson(Map<String, dynamic> json) => _$ReplyFromJson(json);
}
