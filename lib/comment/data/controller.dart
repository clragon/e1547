import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

import 'comment.dart';

class CommentsController extends CursorDataController<Comment>
    with RefreshableController {
  final Client client;

  final int postId;

  CommentsController({required this.client, required this.postId});

  @override
  @protected
  Future<List<Comment>> provide(String page, bool force) =>
      client.comments(postId, page, force: force);

  @override
  @protected
  int getId(Comment item) => item.id;
}

class CommentsProvider
    extends SelectiveChangeNotifierProvider<Client, CommentsController> {
  CommentsProvider({required int postId, super.child, super.builder})
      : super(
          create: (context, client) =>
              CommentsController(client: client, postId: postId),
          selector: (context, client) => [postId],
        );
}

class CommentController
    extends ProxyValueNotifier<Comment, CommentsController> {
  final Client client;

  final int id;

  CommentController({
    required this.client,
    required this.id,
    required super.parent,
  });

  @override
  Comment? fromParent() =>
      parent?.itemList?.firstWhereOrNull((value) => value.id == id);

  @override
  void toParent(Comment value) {
    if (!orphan) {
      parent!.updateItem(
        parent!.itemList!.indexOf(this.value),
        value,
        force: true,
      );
    }
  }

  Future<bool> vote({
    required bool upvote,
    required bool replace,
  }) async {
    try {
      await client.voteComment(value.id, upvote, replace);
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
      return true;
    } on DioError {
      return false;
    }
  }
}

class CommentProvider extends SelectiveChangeNotifierProvider2<Client,
    CommentsController, CommentController> {
  CommentProvider({required int id, super.child, super.builder})
      : super(
          create: (context, client, parent) =>
              CommentController(client: client, id: id, parent: parent),
          selector: (context, client, parent) => [id],
        );
}
