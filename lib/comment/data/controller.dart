import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class CommentsController extends PageClientDataController<Comment> {
  CommentsController({
    required this.client,
    required this.postId,
    required this.denylist,
    bool? orderByOldest,
  }) : _orderByOldest = orderByOldest ?? true {
    denylist.addListener(applyFilter);
  }

  @override
  final Client client;
  final int postId;
  final DenylistService denylist;

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
      client.comments(
        page,
        search: QueryMap({
          'group_by': 'comment',
          'search[post_id]': postId,
          'search[order]': orderByOldest ? 'id_asc' : 'id_desc',
        }),
        force: force,
        cancelToken: cancelToken,
      );

  @override
  List<Comment>? filter(List<Comment>? items) => super.filter(
      items?.whereNot((e) => denylist.denies('user:${e.creatorId}')).toList());

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
    if (comment.voteStatus == VoteStatus.unknown) {
      if (upvote) {
        comment = comment.copyWith(
          score: comment.score + 1,
          voteStatus: VoteStatus.upvoted,
        );
      } else {
        comment = comment.copyWith(
          score: comment.score - 1,
          voteStatus: VoteStatus.downvoted,
        );
      }
    } else {
      if (upvote) {
        if (comment.voteStatus == VoteStatus.upvoted) {
          comment = comment.copyWith(
            score: comment.score - 1,
            voteStatus: VoteStatus.unknown,
          );
        } else {
          comment = comment.copyWith(
            score: comment.score + 2,
            voteStatus: VoteStatus.upvoted,
          );
        }
      } else {
        if (comment.voteStatus == VoteStatus.upvoted) {
          comment = comment.copyWith(
            score: comment.score - 2,
            voteStatus: VoteStatus.downvoted,
          );
        } else {
          comment = comment.copyWith(
            score: comment.score + 1,
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

  @override
  void dispose() {
    denylist.removeListener(applyFilter);
    super.dispose();
  }
}

class CommentsProvider extends SubChangeNotifierProvider2<Client,
    DenylistService, CommentsController> {
  CommentsProvider({required int postId, super.child, super.builder})
      : super(
          create: (context, client, denylist) => CommentsController(
              client: client, postId: postId, denylist: denylist),
          keys: (context) => [postId],
        );
}
