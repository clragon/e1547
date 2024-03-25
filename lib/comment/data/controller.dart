import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:flutter/material.dart';

class CommentController extends PageClientDataController<Comment> {
  CommentController({
    required this.client,
    required this.postId,
    bool? orderByOldest,
  }) : _orderByOldest = orderByOldest ?? true {
    client.traits.addListener(applyFilter);
  }

  @override
  final Client client;
  final int postId;

  bool _orderByOldest;
  bool get orderByOldest => _orderByOldest;
  set orderByOldest(bool value) {
    if (_orderByOldest == value) return;
    _orderByOldest = value;
    refresh();
  }

  @override
  @protected
  Future<List<Comment>> fetch(
    int page,
    bool force,
  ) =>
      client.comments.byPost(
        id: postId,
        page: page,
        force: force,
        cancelToken: cancelToken,
        ascending: orderByOldest,
      );

  @override
  List<Comment>? filter(List<Comment>? items) => super.filter(items
      ?.whereNot(
          (e) => client.traits.value.denylist.contains('user:${e.creatorId}'))
      .toList());

  void replaceComment(Comment comment) => updateItem(
        items?.indexWhere((e) => e.id == comment.id) ?? -1,
        comment,
      );

  Future<bool> vote({
    required Comment comment,
    required bool upvote,
    required bool replace,
  }) async {
    assertOwnsItem(comment);
    replaceComment(
      comment.copyWith(
        vote: comment.vote?.withVote(
          upvote ? VoteStatus.upvoted : VoteStatus.downvoted,
          replace,
        ),
      ),
    );
    try {
      await client.comments.vote(
        id: comment.id,
        upvote: upvote,
        replace: replace,
      );
      evictCache();
      return true;
    } on ClientException {
      replaceComment(comment);
      return false;
    }
  }

  @override
  void dispose() {
    client.traits.removeListener(applyFilter);
    super.dispose();
  }
}

class CommentProvider
    extends SubChangeNotifierProvider<Client, CommentController> {
  CommentProvider({required int postId, super.child, super.builder})
      : super(
          create: (context, client) =>
              CommentController(client: client, postId: postId),
          keys: (context) => [postId],
        );
}
