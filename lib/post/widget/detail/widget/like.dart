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
    final domain = DomainRef.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await domain.posts.vote(id: post.id, upvote: upvote, replace: !isLiked);
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
    final canVote = DomainRef.of(context).hasLogin;

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
              return true;
            } on Exception {
              messenger.showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 1),
                  content: Text('Failed to add Post #${post.id} to favorites'),
                ),
              );
              return false;
            }
          }
        },
      ),
    );
  }
}
