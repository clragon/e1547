import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';
part 'tag.g.dart';

@freezed
class Tag with _$Tag {
  const factory Tag({
    required int id,
    required String name,
    required int postCount,
    required String relatedTags,
    required DateTime relatedTagsUpdatedAt,
    required int category,
    required bool isLocked,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Tag;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}
