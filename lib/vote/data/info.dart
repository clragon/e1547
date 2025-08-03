class VoteInfo {
  VoteInfo({required this.score, this.status = VoteStatus.unknown});

  factory VoteInfo.fromJson(Map<String, dynamic> json) => VoteInfo(
    score: json['score'],
    status: VoteStatus.values.asNameMap()[json['status']] ?? VoteStatus.unknown,
  );

  Map<String, dynamic> toJson() => {'score': score, 'status': status.name};

  final int score;
  final VoteStatus status;

  VoteInfo copyWith({int? score, VoteStatus? status}) =>
      VoteInfo(score: score ?? this.score, status: status ?? this.status);

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
