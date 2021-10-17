import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

enum VoteStatus {
  upvoted,
  unknown,
  downvoted,
}

class VoteDisplay extends StatelessWidget {
  final VoteStatus status;
  final int score;
  final Future<bool> Function(bool isVoted)? onUpvote;
  final Future<bool> Function(bool isVoted)? onDownvote;
  final EdgeInsetsGeometry? padding;

  const VoteDisplay({
    required this.status,
    required this.score,
    this.onUpvote,
    this.onDownvote,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: LikeButton(
            isLiked: status == VoteStatus.upvoted,
            circleColor: CircleColor(start: Colors.orange, end: Colors.amber),
            bubblesColor: BubblesColor(
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
          padding: padding ?? EdgeInsets.symmetric(horizontal: 8),
          child: Text(score.toString()),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: LikeButton(
            isLiked: status == VoteStatus.downvoted,
            circleColor:
                CircleColor(start: Colors.blue, end: Colors.cyanAccent),
            bubblesColor: BubblesColor(
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
