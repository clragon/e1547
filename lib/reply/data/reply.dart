import 'package:e1547/comment/comment.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'reply.freezed.dart';
part 'reply.g.dart';

@freezed
abstract class Reply with _$Reply {
  const factory Reply({
    required int id,
    required int creatorId,
    required String creator,
    required DateTime createdAt,
    required int? updaterId,
    required String? updater,
    required DateTime updatedAt,
    required String body,
    required int topicId,
    required WarningType? warning,
    required bool hidden,
  }) = _Reply;

  factory Reply.fromJson(Map<String, dynamic> json) => _$ReplyFromJson(json);
}
