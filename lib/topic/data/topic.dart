import 'package:freezed_annotation/freezed_annotation.dart';

part 'topic.freezed.dart';
part 'topic.g.dart';

@freezed
abstract class Topic with _$Topic {
  const factory Topic({
    required int id,
    required int creatorId,
    required String creator,
    required DateTime createdAt,
    required int updaterId,
    required String updater,
    required DateTime updatedAt,
    required String title,
    required int responseCount,
    required bool sticky,
    required bool locked,
    required bool hidden,
    required int categoryId,
  }) = _Topic;

  factory Topic.fromJson(dynamic json) => _$TopicFromJson(json);
}
