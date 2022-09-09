import 'package:freezed_annotation/freezed_annotation.dart';

part 'wiki.freezed.dart';
part 'wiki.g.dart';

@freezed
class Wiki with _$Wiki {
  const factory Wiki({
    required int id,
    required DateTime createdAt,
    required DateTime? updatedAt,
    required String title,
    required String body,
    required int creatorId,
    required bool isLocked,
    required int? updaterId,
    required bool isDeleted,
    required List<String> otherNames,
    required String creatorName,
    required int categoryName,
  }) = _Wiki;

  factory Wiki.fromJson(Map<String, dynamic> json) => _$WikiFromJson(json);
}
