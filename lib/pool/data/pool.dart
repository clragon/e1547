import 'package:freezed_annotation/freezed_annotation.dart';

part 'pool.freezed.dart';
part 'pool.g.dart';

@freezed
class Pool with _$Pool {
  const factory Pool({
    required int id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int creatorId,
    required String description,
    required bool isActive,
    required Category category,
    required bool isDeleted,
    required List<int> postIds,
    required String creatorName,
    required int postCount,
  }) = _Pool;

  factory Pool.fromJson(Map<String, dynamic> json) => _$PoolFromJson(json);
}

@JsonEnum()
enum Category { series, collection }
