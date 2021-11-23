import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class LikeDisplay extends StatelessWidget {
  final Post post;

  const LikeDisplay({required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedSelector(
              animation: post,
              selector: () => [post.voteStatus],
              builder: (context, child) => VoteDisplay(
                status: post.voteStatus,
                score: post.score.total,
                onUpvote: (isLiked) async {
                  if (client.hasLogin) {
                    post.tryVote(
                        context: context, upvote: true, replace: !isLiked);
                    return !isLiked;
                  } else {
                    return false;
                  }
                },
                onDownvote: (isLiked) async {
                  if (client.hasLogin) {
                    post.tryVote(
                        context: context, upvote: false, replace: !isLiked);
                    return !isLiked;
                  } else {
                    return false;
                  }
                },
              ),
            ),
            AnimatedSelector(
              animation: post,
              selector: () => [post.isFavorited],
              builder: (context, child) => Row(
                children: [
                  Text(post.favCount.toString()),
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

class FavoriteButton extends StatelessWidget {
  final Post post;

  const FavoriteButton({required this.post});

  @override
  Widget build(BuildContext context) {
    return AnimatedSelector(
      animation: post,
      selector: () => [post.isFavorited],
      builder: (context, child) => LikeButton(
        isLiked: post.isFavorited,
        circleColor: CircleColor(start: Colors.pink, end: Colors.red),
        bubblesColor: BubblesColor(
            dotPrimaryColor: Colors.pink, dotSecondaryColor: Colors.red),
        likeBuilder: (bool isLiked) => Icon(
          Icons.favorite,
          color:
          isLiked ? Colors.pinkAccent : Theme.of(context).iconTheme.color,
        ),
        onTap: (isLiked) async {
          if (isLiked) {
            post.tryRemoveFav(context);
            return false;
          } else {
            post.tryAddFav(
              context,
              cooldown: Duration(seconds: 1),
            );
            return true;
          }
        },
      ),
    );
  }
}
