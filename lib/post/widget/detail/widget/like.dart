import 'package:e1547/domain/domain.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/vote/vote.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class LikeDisplay extends StatelessWidget {
  const LikeDisplay({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    const canVote = 1 == 1; // client.hasLogin;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            VoteDisplay(
              status: post.vote.status,
              score: post.vote.score,
              onUpvote: canVote
                  ? (isLiked) async {
                      messenger.showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 1),
                          content: Text('Failed to upvote Post #${post.id}'),
                        ),
                      );
                      return !isLiked;
                    }
                  : null,
              onDownvote: canVote
                  ? (isLiked) async {
                      messenger.showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 1),
                          content: Text('Failed to downvote Post #${post.id}'),
                        ),
                      );
                      return !isLiked;
                    }
                  : null,
            ),
            Row(
              children: [
                Text(post.favCount.toString()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.favorite,
                    color: post.isFavorited
                        ? Colors.pinkAccent
                        : IconTheme.of(context).color,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final client = DomainRef.of(context);

    return InkResponse(
      onTap: () {},
      child: LikeButton(
        isLiked: post.isFavorited,
        circleColor: const CircleColor(start: Colors.pink, end: Colors.red),
        bubblesColor: const BubblesColor(
          dotPrimaryColor: Colors.pink,
          dotSecondaryColor: Colors.red,
        ),
        likeBuilder: (isLiked) => Icon(
          Icons.favorite,
          color: isLiked ? Colors.pinkAccent : IconTheme.of(context).color,
        ),
        onTap: (isLiked) async {
          ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
          if (isLiked) {
            try {
              await client.favorites.remove(post.id);
              messenger.showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 1),
                  content: Text(
                    'Failed to remove Post #${post.id} from favorites',
                  ),
                ),
              );
            } on Exception {
              messenger.showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 1),
                  content: Text('Failed to add Post #${post.id} to favorites'),
                ),
              );
            }
            return false;
          } else {
            try {
              await client.favorites.add(post.id);
              /*
              if (upvote) {
                controller.vote(
                  post: controller.postById(post.id)!,
                  upvote: true,
                  replace: true,
                );
              }
              */
            } on Exception {
              messenger.showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 1),
                  content: Text('Failed to add Post #${post.id} to favorites'),
                ),
              );
            }
            return true;
          }
        },
      ),
    );
  }
}
