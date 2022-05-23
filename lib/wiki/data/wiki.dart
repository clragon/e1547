import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wiki.g.dart';

@JsonSerializable()
@CopyWith()
class Wiki {
  Wiki({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.body,
    required this.creatorId,
    required this.isLocked,
    required this.updaterId,
    required this.isDeleted,
    required this.otherNames,
    required this.creatorName,
    required this.categoryName,
  });

  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String title;
  final String body;
  final int creatorId;
  final bool isLocked;
  final int? updaterId;
  final bool isDeleted;
  final List<String> otherNames;
  final String creatorName;
  final int categoryName;

  factory Wiki.fromJson(Map<String, dynamic> json) => _$WikiFromJson(json);

  Map<String, dynamic> toJson() => _$WikiToJson(this);
}
