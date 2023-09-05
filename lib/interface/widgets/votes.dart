import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

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
          onTap: () {},
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
            onTap: onUpvote,
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
          onTap: () {},
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
            onTap: onDownvote,
          ),
        ),
      ],
    );
  }
}
