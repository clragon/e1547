import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

import 'comment.dart';

class CommentsController extends CursorClientDataController<Comment>
    with RefreshableController {
  CommentsController({required this.client, required this.postId});

  @override
  final Client client;

  final int postId;

  @override
  @protected
  Future<List<Comment>> fetch(String page, bool force) => client.comments(
        postId,
        page,
        force: force,
        cancelToken: cancelToken,
      );

  @override
  @protected
  int getId(Comment item) => item.id;

  void replaceComment(Comment comment) {
    int index = itemList?.indexWhere((e) => e.id == comment.id) ?? -1;
    if (index == -1) {
      throw StateError('Comment isnt owned by this controller');
    }
    updateItem(index, comment);
  }

  Future<bool> vote({
    required Comment comment,
    required bool upvote,
    required bool replace,
  }) async {
    assertOwnsItem(comment);
    Comment value = comment;
    if (value.voteStatus == VoteStatus.unknown) {
      if (upvote) {
        value = value.copyWith(
          score: value.score + 1,
          voteStatus: VoteStatus.upvoted,
        );
      } else {
        value = value.copyWith(
          score: value.score - 1,
          voteStatus: VoteStatus.downvoted,
        );
      }
    } else {
      if (upvote) {
        if (value.voteStatus == VoteStatus.upvoted) {
          value = value.copyWith(
            score: value.score - 1,
            voteStatus: VoteStatus.unknown,
          );
        } else {
          value = value.copyWith(
            score: value.score + 2,
            voteStatus: VoteStatus.upvoted,
          );
        }
      } else {
        if (value.voteStatus == VoteStatus.upvoted) {
          value = value.copyWith(
            score: value.score - 2,
            voteStatus: VoteStatus.downvoted,
          );
        } else {
          value = value.copyWith(
            score: value.score + 1,
            voteStatus: VoteStatus.unknown,
          );
        }
      }
    }
    replaceComment(comment);
    try {
      await client.voteComment(comment.id, upvote, replace);
      evictCache();
      return true;
    } on ClientException {
      return false;
    }
  }
}

class CommentsProvider
    extends SubChangeNotifierProvider<Client, CommentsController> {
  CommentsProvider({required int postId, super.child, super.builder})
      : super(
          create: (context, client) =>
              CommentsController(client: client, postId: postId),
          selector: (context) => [postId],
        );
}
