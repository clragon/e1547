import 'package:e1547/post.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class LikeDisplay extends StatelessWidget {
  final Post post;

  LikeDisplay({@required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            ValueListenableBuilder(
              valueListenable: post.voteStatus,
              builder: (context, value, child) => Row(
                children: <Widget>[
                  LikeButton(
                    isLiked: post.voteStatus.value == VoteStatus.upvoted,
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
                    child: ValueListenableBuilder(
                      valueListenable: post.score,
                      builder: (context, value, child) =>
                          Text((value ?? 0).toString()),
                    ),
                  ),
                  LikeButton(
                    isLiked: post.voteStatus.value == VoteStatus.downvoted,
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
            ValueListenableBuilder(
              valueListenable: post.favorites,
              builder: (context, value, child) => Row(
                children: <Widget>[
                  Text((post.favorites.value ?? 0).toString()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.favorite),
                  ),
                ],
              ),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }
}
