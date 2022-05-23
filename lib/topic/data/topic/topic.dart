import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'topic.g.dart';

@JsonSerializable()
@CopyWith()
class Topic {
  Topic({
    required this.id,
    required this.creatorId,
    required this.updaterId,
    required this.title,
    required this.responseCount,
    required this.isSticky,
    required this.isLocked,
    required this.isHidden,
    required this.createdAt,
    required this.updatedAt,
    required this.categoryId,
  });

  final int id;
  final int creatorId;
  final int updaterId;
  final String title;
  final int responseCount;
  final bool isSticky;
  final bool isLocked;
  final bool isHidden;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int categoryId;

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);

  Map<String, dynamic> toJson() => _$TopicToJson(this);
}
