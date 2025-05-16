import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required int id,
    required String name,
    required int? avatarId,
    required UserAbout? about,
    required UserStats? stats,
  }) = _User;

  factory User.fromJson(dynamic json) => _$UserFromJson(json);
}

@freezed
class UserAbout with _$UserAbout {
  const factory UserAbout({required String? bio, required String? comission}) =
      _UserAbout;

  factory UserAbout.fromJson(dynamic json) => _$UserAboutFromJson(json);
}

@freezed
class UserStats with _$UserStats {
  const factory UserStats({
    required DateTime? createdAt,
    required String? levelString,
    required int? favoriteCount,
    required int? postUpdateCount,
    required int? postUploadCount,
    required int? forumPostCount,
    required int? commentCount,
  }) = _UserStats;

  factory UserStats.fromJson(dynamic json) => _$UserStatsFromJson(json);
}
