class VoteInfo {
  VoteInfo({
    required this.score,
    this.status = VoteStatus.unknown,
  });

  factory VoteInfo.fromJson(Map<String, dynamic> json) => VoteInfo(
        score: json['score'],
        status:
            VoteStatus.values.asNameMap()[json['status']] ?? VoteStatus.unknown,
      );

  Map<String, dynamic> toJson() => {
        'score': score,
        'status': status.name,
      };

  final int score;
  final VoteStatus status;

  VoteInfo copyWith({
    int? score,
    VoteStatus? status,
  }) =>
      VoteInfo(
        score: score ?? this.score,
        status: status ?? this.status,
      );

  VoteInfo withVote(VoteStatus status, [bool replace = false]) {
    switch (status) {
      case VoteStatus.upvoted:
        switch (this.status) {
          case VoteStatus.upvoted:
            if (replace) return this;
            return copyWith(score: score - 1, status: VoteStatus.unknown);
          case VoteStatus.downvoted:
            return copyWith(score: score - 2, status: status);
          case VoteStatus.unknown:
            return copyWith(score: score + 1, status: status);
        }
      case VoteStatus.downvoted:
        switch (this.status) {
          case VoteStatus.upvoted:
            return copyWith(score: score + 2, status: status);
          case VoteStatus.downvoted:
            if (replace) return this;
            return copyWith(score: score + 1, status: VoteStatus.unknown);
          case VoteStatus.unknown:
            return copyWith(score: score - 1, status: status);
        }
      case VoteStatus.unknown:
        switch (this.status) {
          case VoteStatus.upvoted:
            return copyWith(score: score - 1, status: status);
          case VoteStatus.downvoted:
            return copyWith(score: score + 1, status: status);
          case VoteStatus.unknown:
            return this;
        }
    }
  }
}

enum VoteStatus {
  upvoted,
  unknown,
  downvoted,
}
