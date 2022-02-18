import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

import 'comment.dart';

Future<bool> replyComment({
  required BuildContext context,
  required Comment comment,
}) {
  String body = comment.body;
  body = body
      .replaceFirstMapped(
          RegExp(r'\[quote\]".*?":/user/show/[0-9]* said:.*\[\/quote\]',
              dotAll: true),
          (match) => '')
      .trim();
  body =
      '[quote]"${comment.creatorName}":/users/${comment.creatorId} said:\n$body[/quote]\n';
  return writeComment(context: context, postId: comment.postId, text: body);
}

Future<bool> editComment(
        {required BuildContext context, required Comment comment}) =>
    writeComment(postId: comment.postId, context: context, comment: comment);

Future<bool> writeComment({
  required BuildContext context,
  required int postId,
  String? text,
  Comment? comment,
}) async {
  bool sent = false;
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => TextEditor(
        title: '#$postId comment',
        content: text ?? (comment?.body),
        onSubmit: (context, text) async {
          if (text.isNotEmpty) {
            try {
              await client.postComment(postId, text, comment: comment);
              sent = true;
              return true;
            } on DioError {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: Duration(seconds: 1),
                content: Text('Failed to send comment!'),
                behavior: SnackBarBehavior.floating,
              ));
              return false;
            }
          }
          return false;
        },
      ),
    ),
  );
  return sent;
}

extension Voting on Comment {
  Future<void> tryVote(
      {required BuildContext context,
      required bool upvote,
      required bool replace}) async {
    if (await client.voteComment(id, upvote, replace)) {
      if (voteStatus == VoteStatus.unknown) {
        if (upvote) {
          score += 1;
          voteStatus = VoteStatus.upvoted;
        } else {
          score -= 1;
          voteStatus = VoteStatus.downvoted;
        }
      } else {
        if (upvote) {
          if (voteStatus == VoteStatus.upvoted) {
            score -= 1;
            voteStatus = VoteStatus.unknown;
          } else {
            score += 2;
            voteStatus = VoteStatus.upvoted;
          }
        } else {
          if (voteStatus == VoteStatus.upvoted) {
            score -= 2;
            voteStatus = VoteStatus.downvoted;
          } else {
            score += 1;
            voteStatus = VoteStatus.unknown;
          }
        }
      }
      notifyListeners();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Failed to vote on comment #$id'),
      ));
    }
  }
}

extension Transitioning on Comment {
  String get hero => getCommentHero(id);
}

String getCommentHero(int id) => 'comment_$id';
