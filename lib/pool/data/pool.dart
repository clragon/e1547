import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pool.g.dart';

@JsonSerializable()
@CopyWith()
class Pool {
  Pool({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.creatorId,
    required this.description,
    required this.isActive,
    required this.category,
    required this.isDeleted,
    required this.postIds,
    required this.creatorName,
    required this.postCount,
  });

  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int creatorId;
  final String description;
  final bool isActive;
  final Category category;
  final bool isDeleted;
  final List<int> postIds;
  final String creatorName;
  final int postCount;

  factory Pool.fromJson(Map<String, dynamic> json) => _$PoolFromJson(json);

  Map<String, dynamic> toJson() => _$PoolToJson(this);
}

@JsonEnum()
enum Category { series, collection }
