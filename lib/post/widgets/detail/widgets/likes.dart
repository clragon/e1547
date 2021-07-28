import 'package:e1547/post.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class LikeDisplay extends StatelessWidget {
  final Post post;

  LikeDisplay({required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedBuilder(
              animation: post,
              builder: (context, child) => Row(
                children: [
                  LikeButton(
                    isLiked: post.voteStatus == VoteStatus.upvoted,
                    likeBuilder: (bool isLiked) => Icon(
                      Icons.arrow_upward,
                      color: isLiked
                          ? Colors.deepOrange
                          : Theme.of(context).iconTheme.color,
                    ),
                    onTap: (isLiked) async {
                      if (post.isLoggedIn) {
                        post.tryVote(
                            context: context, upvote: true, replace: !isLiked);
                        return !isLiked;
                      } else {
                        return false;
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text((post.score.total).toString()),
                  ),
                  LikeButton(
                    isLiked: post.voteStatus == VoteStatus.downvoted,
                    circleColor:
                        CircleColor(start: Colors.blue, end: Colors.cyanAccent),
                    bubblesColor: BubblesColor(
                        dotPrimaryColor: Colors.blue,
                        dotSecondaryColor: Colors.cyanAccent),
                    likeBuilder: (bool isLiked) {
                      return Icon(
                        Icons.arrow_downward,
                        color: isLiked
                            ? Colors.blue
                            : Theme.of(context).iconTheme.color,
                      );
                    },
                    onTap: (isLiked) async {
                      if (post.isLoggedIn) {
                        post.tryVote(
                            context: context, upvote: false, replace: !isLiked);
                        return !isLiked;
                      } else {
                        return false;
                      }
                    },
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(post.favCount.toString()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.favorite),
                ),
              ],
            ),
          ],
        ),
        Divider(),
      ],
    );
  }
}
