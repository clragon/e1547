import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class LikeDisplay extends StatelessWidget {
  final Post post;
  final PostController? controller;

  const LikeDisplay({required this.post, this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedSelector(
              animation: Listenable.merge([controller]),
              selector: () => [post.voteStatus],
              builder: (context, child) => VoteDisplay(
                status: post.voteStatus,
                score: post.score.total,
                onUpvote: controller != null
                    ? (isLiked) async {
                        if (client.hasLogin) {
                          controller!.vote(
                              context: context,
                              post: post,
                              upvote: true,
                              replace: !isLiked);
                          return !isLiked;
                        } else {
                          return false;
                        }
                      }
                    : null,
                onDownvote: controller != null
                    ? (isLiked) async {
                        if (client.hasLogin) {
                          controller!.vote(
                              context: context,
                              post: post,
                              upvote: false,
                              replace: !isLiked);
                          return !isLiked;
                        } else {
                          return false;
                        }
                      }
                    : null,
              ),
            ),
            AnimatedSelector(
              animation: Listenable.merge([controller]),
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
  final PostController controller;

  const FavoriteButton({required this.post, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedSelector(
      animation: Listenable.merge([controller]),
      selector: () => [post.isFavorited],
      builder: (context, child) => LikeButton(
        isLiked: post.isFavorited,
        circleColor: CircleColor(start: Colors.pink, end: Colors.red),
        bubblesColor: BubblesColor(
            dotPrimaryColor: Colors.pink, dotSecondaryColor: Colors.red),
        likeBuilder: (isLiked) => Icon(
          Icons.favorite,
          color:
              isLiked ? Colors.pinkAccent : Theme.of(context).iconTheme.color,
        ),
        onTap: (isLiked) async {
          if (isLiked) {
            controller.unfav(context, post);
            return false;
          } else {
            controller.fav(
              context,
              post,
              cooldown: Duration(seconds: 1),
            );
            return true;
          }
        },
      ),
    );
  }
}
