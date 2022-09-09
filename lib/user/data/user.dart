import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required int wikiPageVersionCount,
    required int artistVersionCount,
    required int poolVersionCount,
    required int forumPostCount,
    required int commentCount,
    required int flagCount,
    required int positiveFeedbackCount,
    required int neutralFeedbackCount,
    required int negativeFeedbackCount,
    required int uploadLimit,
    required int id,
    required DateTime createdAt,
    required String name,
    required int level,
    required int baseUploadLimit,
    required int postUploadCount,
    required int postUpdateCount,
    required int noteUpdateCount,
    required bool isBanned,
    required bool canApprovePosts,
    required bool canUploadFree,
    required String levelString,
    required int? avatarId,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
