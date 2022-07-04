import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

import 'comment.dart';

class CommentsController extends CursorDataController<Comment>
    with RefreshableController, HostableController {
  final int postId;

  CommentsController({required this.postId});

  @override
  @protected
  Future<List<Comment>> provide(String page, bool force) =>
      client.comments(postId, page, force: force);

  @override
  @protected
  int getId(Comment item) => item.id;

  Future<bool> vote({
    required Comment comment,
    required bool upvote,
    required bool replace,
  }) async {
    try {
      await client.voteComment(comment.id, upvote, replace);
      Comment updated = comment;
      if (comment.voteStatus == VoteStatus.unknown) {
        if (upvote) {
          updated = updated.copyWith(
            score: updated.score + 1,
            voteStatus: VoteStatus.upvoted,
          );
        } else {
          updated = updated.copyWith(
            score: updated.score - 1,
            voteStatus: VoteStatus.downvoted,
          );
        }
      } else {
        if (upvote) {
          if (comment.voteStatus == VoteStatus.upvoted) {
            updated = updated.copyWith(
              score: updated.score - 1,
              voteStatus: VoteStatus.unknown,
            );
          } else {
            updated = updated.copyWith(
              score: updated.score + 2,
              voteStatus: VoteStatus.upvoted,
            );
          }
        } else {
          if (comment.voteStatus == VoteStatus.upvoted) {
            updated = updated.copyWith(
              score: updated.score - 2,
              voteStatus: VoteStatus.downvoted,
            );
          } else {
            updated = updated.copyWith(
              score: updated.score + 1,
              voteStatus: VoteStatus.unknown,
            );
          }
        }
      }
      updateItem(itemList!.indexOf(comment), updated, force: true);
      return true;
    } on DioError {
      return false;
    }
  }
}
