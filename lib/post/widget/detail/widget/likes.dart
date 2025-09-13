import 'package:e1547/domain/domain.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class LikeDisplay extends StatelessWidget {
  const LikeDisplay({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    final messenger = ScaffoldMessenger.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MutationBuilder(
              mutation: domain.posts.useVote(id: post.id),
              builder: (context, state, mutate) {
                final bool enabled = domain.hasLogin && !state.isLoading;
                return VoteDisplay(
                  status: post.vote.status,
                  score: post.vote.score,
                  onUpvote: enabled
                      ? (isLiked) async {
                          try {
                            await mutate((upvote: true, replace: !isLiked));
                          } on Exception {
                            messenger.showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 1),
                                content: Text(
                                  'Failed to upvote Post #${post.id}',
                                ),
                              ),
                            );
                          }
                        }
                      : null,
                  onDownvote: enabled
                      ? (isLiked) async {
                          try {
                            await mutate((upvote: false, replace: !isLiked));
                          } on Exception {
                            messenger.showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 1),
                                content: Text(
                                  'Failed to downvote Post #${post.id}',
                                ),
                              ),
                            );
                          }
                        }
                      : null,
                );
              },
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
    final domain = context.watch<Domain>();
    final messenger = ScaffoldMessenger.of(context);

    return MutationBuilder(
      mutation: domain.favorites.useSetFavorite(id: post.id),
      builder: (context, state, mutate) {
        return InkResponse(
          onTap: state.isLoading ? null : () {},
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
              (() async {
                try {
                  await mutate(!isLiked);
                } on Exception {
                  messenger.showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 1),
                      content: Text(
                        isLiked
                            ? 'Failed to remove Post #${post.id} from favorites'
                            : 'Failed to add Post #${post.id} to favorites',
                      ),
                    ),
                  );
                }
              })();
              return null;
            },
          ),
        );
      },
    );
  }
}
