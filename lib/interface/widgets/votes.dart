import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

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

class VoteDisplay extends StatelessWidget {
  const VoteDisplay({
    super.key,
    required this.status,
    required this.score,
    this.onUpvote,
    this.onDownvote,
    this.padding,
  });

  final VoteStatus status;
  final int score;
  final Future<bool> Function(bool isVoted)? onUpvote;
  final Future<bool> Function(bool isVoted)? onDownvote;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkResponse(
          onTap: onUpvote != null ? () {} : null,
          child: LikeButton(
            isLiked: status == VoteStatus.upvoted,
            circleColor:
                const CircleColor(start: Colors.orange, end: Colors.amber),
            bubblesColor: const BubblesColor(
              dotPrimaryColor: Colors.amber,
              dotSecondaryColor: Colors.orange,
              dotThirdColor: Colors.deepOrange,
              dotLastColor: Colors.redAccent,
            ),
            likeBuilder: (bool isLiked) => Icon(
              Icons.arrow_upward,
              color: isLiked ? Colors.deepOrange : null,
            ),
            onTap: onUpvote ?? (_) async => status == VoteStatus.upvoted,
          ),
        ),
        Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            score.toString(),
            style: TextStyle(
              color: switch (status) {
                VoteStatus.upvoted => Colors.deepOrange,
                VoteStatus.downvoted => Colors.blue,
                VoteStatus.unknown => null,
              },
            ),
          ),
        ),
        InkResponse(
          onTap: onDownvote != null ? () {} : null,
          child: LikeButton(
            isLiked: status == VoteStatus.downvoted,
            circleColor:
                const CircleColor(start: Colors.blue, end: Colors.cyanAccent),
            bubblesColor: const BubblesColor(
              dotPrimaryColor: Colors.cyanAccent,
              dotSecondaryColor: Colors.blue,
              dotThirdColor: Colors.indigoAccent,
              dotLastColor: Colors.indigo,
            ),
            likeBuilder: (bool isLiked) => Icon(
              Icons.arrow_downward,
              color: isLiked ? Colors.blue : null,
            ),
            onTap: onDownvote ?? (_) async => status == VoteStatus.downvoted,
          ),
        ),
      ],
    );
  }
}
