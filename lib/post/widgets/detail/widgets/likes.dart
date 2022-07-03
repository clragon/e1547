import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class LikeDisplay extends StatelessWidget {
  final PostController post;

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
              selector: () => [post.value.voteStatus],
              builder: (context, child) => VoteDisplay(
                status: post.value.voteStatus,
                score: post.value.score.total,
                onUpvote: (isLiked) async {
                  if (client.hasLogin) {
                    post.vote(upvote: true, replace: !isLiked).then((value) {
                      if (!value) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: const Duration(seconds: 1),
                          content:
                              Text('Failed to upvote Post #${post.value.id}'),
                        ));
                      }
                    });
                    return !isLiked;
                  } else {
                    return false;
                  }
                },
                onDownvote: (isLiked) async {
                  if (client.hasLogin) {
                    post.vote(upvote: false, replace: !isLiked).then((value) {
                      if (!value) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: const Duration(seconds: 1),
                          content:
                              Text('Failed to downvote Post #${post.value.id}'),
                        ));
                      }
                    });
                    return !isLiked;
                  } else {
                    return false;
                  }
                },
              ),
            ),
            AnimatedSelector(
              animation: post,
              selector: () => [post.value.isFavorited],
              builder: (context, child) => Row(
                children: [
                  Text(post.value.favCount.toString()),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.favorite),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}

class FavoriteButton extends StatelessWidget {
  final PostController post;

  const FavoriteButton({required this.post});

  @override
  Widget build(BuildContext context) {
    return AnimatedSelector(
      animation: post,
      selector: () => [post.value.isFavorited],
      builder: (context, child) => LikeButton(
        isLiked: post.value.isFavorited,
        circleColor: const CircleColor(start: Colors.pink, end: Colors.red),
        bubblesColor: const BubblesColor(
            dotPrimaryColor: Colors.pink, dotSecondaryColor: Colors.red),
        likeBuilder: (isLiked) => Icon(
          Icons.favorite,
          color:
              isLiked ? Colors.pinkAccent : Theme.of(context).iconTheme.color,
        ),
        onTap: (isLiked) async {
          if (isLiked) {
            post.unfav().then((value) {
              if (!value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 1),
                    content: Text(
                        'Failed to remove Post #${post.value.id} from favorites'),
                  ),
                );
              }
            });
            return false;
          } else {
            post.fav().then((value) {
              if (!value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 1),
                    content: Text(
                        'Failed to add Post #${post.value.id} to favorites'),
                  ),
                );
              }
            });
            return true;
          }
        },
      ),
    );
  }
}
