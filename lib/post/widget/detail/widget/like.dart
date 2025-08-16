import 'dart:async';

import 'package:e1547/domain/domain.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/vote/vote.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class LikeDisplay extends StatelessWidget {
  const LikeDisplay({super.key, required this.post});

  final Post post;

  Future<bool> vote(
    BuildContext context, {
    required bool upvote,
    required bool isLiked,
  }) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      return !isLiked;
    } on Exception {
      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          content: Text(
            'Failed to ${!isLiked ? "upvote" : "downvote"} Post #${post.id}',
          ),
        ),
      );
      return isLiked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final domain = DomainRef.of(context);
    final canVote = domain.hasLogin;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            VoteDisplay(
              status: post.vote.status,
              score: post.vote.score,
              onUpvote: canVote
                  ? (isLiked) => vote(context, upvote: true, isLiked: isLiked)
                  : null,
              onDownvote: canVote
                  ? (isLiked) => vote(context, upvote: false, isLiked: isLiked)
                  : null,
            ),
            Row(
              children: [
                Text(post.favCount.toString()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: LikeButton(
                    isLiked: post.isFavorited,
                    circleColor: const CircleColor(
                      start: Colors.pink,
                      end: Colors.red,
                    ),
                    bubblesColor: const BubblesColor(
                      dotPrimaryColor: Colors.pink,
                      dotSecondaryColor: Colors.red,
                    ),
                    likeBuilder: (isLiked) => Icon(
                      Icons.favorite,
                      color: isLiked
                          ? Colors.pinkAccent
                          : IconTheme.of(context).color,
                    ),
                    onTap: (isLiked) async {
                      ScaffoldMessengerState messenger = ScaffoldMessenger.of(
                        context,
                      );
                      if (isLiked) {
                        try {
                          final setFavorite = domain.posts.useSetFavorite(
                            id: post.id,
                          );
                          await setFavorite.mutate(!isLiked);
                          return false;
                        } on Exception {
                          messenger.showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 1),
                              content: Text(
                                'Failed to remove Post #${post.id} from favorites',
                              ),
                            ),
                          );
                          return true;
                        }
                      } else {
                        try {
                          final setFavorite = domain.posts.useSetFavorite(
                            id: post.id,
                          );
                          await setFavorite.mutate(!isLiked);
                          return true;
                        } on Exception {
                          messenger.showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 1),
                              content: Text(
                                'Failed to add Post #${post.id} to favorites',
                              ),
                            ),
                          );
                          return false;
                        }
                      }
                    },
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
