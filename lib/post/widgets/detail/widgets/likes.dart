import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class LikeDisplay extends StatelessWidget {
  const LikeDisplay({required this.controller});

  final PostController controller;

  Post get post => controller.value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedSelector(
              animation: controller,
              selector: () => [post.voteStatus],
              builder: (context, child) => VoteDisplay(
                status: post.voteStatus,
                score: post.score.total,
                onUpvote: (isLiked) async {
                  if (context.read<Client>().hasLogin) {
                    controller
                        .vote(upvote: true, replace: !isLiked)
                        .then((value) {
                      if (!value) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: const Duration(seconds: 1),
                          content: Text('Failed to upvote Post #${post.id}'),
                        ));
                      }
                    });
                    return !isLiked;
                  } else {
                    return false;
                  }
                },
                onDownvote: (isLiked) async {
                  if (context.read<Client>().hasLogin) {
                    controller
                        .vote(upvote: false, replace: !isLiked)
                        .then((value) {
                      if (!value) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: const Duration(seconds: 1),
                          content: Text('Failed to downvote Post #${post.id}'),
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
              animation: controller,
              selector: () => [post.isFavorited],
              builder: (context, child) => Row(
                children: [
                  Text(post.favCount.toString()),
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
  const FavoriteButton({required this.controller});

  final PostController controller;

  Post get post => controller.value;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: () {},
      child: AnimatedSelector(
        animation: controller,
        selector: () => [post.isFavorited],
        builder: (context, child) => LikeButton(
          isLiked: post.isFavorited,
          circleColor: const CircleColor(start: Colors.pink, end: Colors.red),
          bubblesColor: const BubblesColor(
              dotPrimaryColor: Colors.pink, dotSecondaryColor: Colors.red),
          likeBuilder: (isLiked) => Icon(
            Icons.favorite,
            color: isLiked ? Colors.pinkAccent : IconTheme.of(context).color,
          ),
          onTap: (isLiked) async {
            if (isLiked) {
              controller.unfav().then((value) {
                if (!value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 1),
                      content: Text(
                          'Failed to remove Post #${post.id} from favorites'),
                    ),
                  );
                }
              });
              return false;
            } else {
              controller.fav().then((value) {
                if (value) {
                  if (context.read<Settings>().upvoteFavs.value) {
                    controller.vote(upvote: true, replace: true);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 1),
                      content:
                          Text('Failed to add Post #${post.id} to favorites'),
                    ),
                  );
                }
              });
              return true;
            }
          },
        ),
      ),
    );
  }
}
