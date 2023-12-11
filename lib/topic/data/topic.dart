import 'package:deep_pick/deep_pick.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'topic.freezed.dart';
part 'topic.g.dart';

@freezed
class Topic with _$Topic {
  const factory Topic({
    required int id,
    required int creatorId,
    required String title,
    required int responseCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isLocked,
    required int categoryId,
  }) = _Topic;

  factory Topic.fromJson(dynamic json) => _$TopicFromJson(json);
}

extension E621Topic on Topic {
  static Topic fromJson(dynamic json) => pick(json).letOrThrow(
        (pick) => Topic(
          id: pick('id').asIntOrThrow(),
          creatorId: pick('creator_id').asIntOrThrow(),
          title: pick('title').asStringOrThrow(),
          responseCount: pick('response_count').asIntOrThrow(),
          createdAt: pick('created_at').asDateTimeOrThrow(),
          updatedAt: pick('updated_at').asDateTimeOrThrow(),
          isLocked: pick('is_locked').asBoolOrThrow(),
          categoryId: pick('category_id').asIntOrThrow(),
        ),
      );
}
