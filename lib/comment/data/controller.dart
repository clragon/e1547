import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

import 'comment.dart';

class CommentController extends CursorDataController<Comment>
    with RefreshableController, HostableController {
  final int postId;

  CommentController({required this.postId});

  @override
  @protected
  Future<List<Comment>> provide(String page, bool force) =>
      client.comments(postId, page, force: force);

  @override
  @protected
  int getId(Comment item) => item.id;

  Future<void> vote({
    required BuildContext context,
    required Comment comment,
    required bool upvote,
    required bool replace,
  }) async {
    if (await client.voteComment(comment.id, upvote, replace)) {
      if (comment.voteStatus == VoteStatus.unknown) {
        if (upvote) {
          comment.score += 1;
          comment.voteStatus = VoteStatus.upvoted;
        } else {
          comment.score -= 1;
          comment.voteStatus = VoteStatus.downvoted;
        }
      } else {
        if (upvote) {
          if (comment.voteStatus == VoteStatus.upvoted) {
            comment.score -= 1;
            comment.voteStatus = VoteStatus.unknown;
          } else {
            comment.score += 2;
            comment.voteStatus = VoteStatus.upvoted;
          }
        } else {
          if (comment.voteStatus == VoteStatus.upvoted) {
            comment.score -= 2;
            comment.voteStatus = VoteStatus.downvoted;
          } else {
            comment.score += 1;
            comment.voteStatus = VoteStatus.unknown;
          }
        }
      }
      updateItem(itemList!.indexOf(comment), comment, force: true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 1),
        content: Text('Failed to vote on comment #${comment.id}'),
      ));
    }
  }
}
