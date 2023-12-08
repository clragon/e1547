import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required int id,
    required String name,
    required int? avatarId,
    UserStats? stats,
  }) = _User;

  factory User.fromJson(dynamic json) => _$UserFromJson(json);
}

@freezed
class UserStats with _$UserStats {
  const factory UserStats({
    required String levelString,
    required int favoriteCount,
    required int postUpdateCount,
    required int postUploadCount,
    required int forumPostCount,
    required int commentCount,
  }) = _UserStats;

  factory UserStats.fromJson(dynamic json) => _$UserStatsFromJson(json);
}

extension E621User on User {
  static User fromJson(dynamic json) {
    return User(
      id: json['id'],
      name: json['name'],
      avatarId: json['avatar_id'],
      stats: UserStats.fromJson(json),
    );
  }
}
