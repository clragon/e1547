import 'package:freezed_annotation/freezed_annotation.dart';

part 'flag.freezed.dart';
part 'flag.g.dart';

@freezed
class PostFlag with _$PostFlag {
  const factory PostFlag({
    required int id,
    required DateTime createdAt,
    required int postId,
    required String reason,
    required int creatorId,
    required bool isResolved,
    required DateTime updatedAt,
    required bool isDeletion,
    required PostFlagType type,
  }) = _PostFlag;

  factory PostFlag.fromJson(Map<String, dynamic> json) =>
      _$PostFlagFromJson(json);
}

enum PostFlagType { flag, deletion }
