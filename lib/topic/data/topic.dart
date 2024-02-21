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
