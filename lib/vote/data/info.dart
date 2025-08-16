import 'package:freezed_annotation/freezed_annotation.dart';

part 'info.freezed.dart';
part 'info.g.dart';

@freezed
abstract class VoteInfo with _$VoteInfo {
  const factory VoteInfo({
    required int score,
    @Default(VoteStatus.unknown) VoteStatus status,
  }) = _VoteInfo;

  const VoteInfo._();

  factory VoteInfo.fromJson(Map<String, dynamic> json) =>
      _$VoteInfoFromJson(json);

  VoteInfo withVote(bool upvote, [bool replace = false]) => switch (upvote) {
    true => switch (status) {
      VoteStatus.upvoted =>
        replace ? this : copyWith(score: score - 1, status: VoteStatus.unknown),
      VoteStatus.downvoted => copyWith(score: score - 2, status: status),
      VoteStatus.unknown => copyWith(score: score + 1, status: status),
    },
    false => switch (status) {
      VoteStatus.upvoted => copyWith(score: score + 2, status: status),
      VoteStatus.downvoted =>
        replace ? this : copyWith(score: score + 1, status: VoteStatus.unknown),
      VoteStatus.unknown => copyWith(score: score - 1, status: status),
    },
  };
}

enum VoteStatus { upvoted, unknown, downvoted }
