import 'package:freezed_annotation/freezed_annotation.dart';

part 'topic.freezed.dart';
part 'topic.g.dart';

@freezed
class Topic with _$Topic {
  const factory Topic({
    required int id,
    required int creatorId,
    required int updaterId,
    required String title,
    required int responseCount,
    required bool isSticky,
    required bool isLocked,
    required bool isHidden,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int categoryId,
  }) = _Topic;

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);
}
