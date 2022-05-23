import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tag.g.dart';

@JsonSerializable()
@CopyWith()
class Tag {
  Tag({
    required this.id,
    required this.name,
    required this.postCount,
    required this.relatedTags,
    required this.relatedTagsUpdatedAt,
    required this.category,
    required this.isLocked,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final int postCount;
  final String relatedTags;
  final DateTime relatedTagsUpdatedAt;
  final int category;
  final bool isLocked;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  Map<String, dynamic> toJson() => _$TagToJson(this);
}
