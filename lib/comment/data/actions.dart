import 'package:e1547/comment/comment.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/markup/markup.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

Future<bool> replyComment({
  required BuildContext context,
  required Comment comment,
}) {
  String body = comment.body;
  body = body
      .replaceFirstMapped(
        RegExp(
          r'\[quote\]"[\S\s]*?":/user(s|/show)/\d* said:[\S\s]*?\[/quote\]',
        ),
        (match) => '',
      )
      .trim();
  body =
      '[quote]"${comment.creatorName}":/users/${comment.creatorId} said:\n$body[/quote]\n';
  return writeComment(context: context, postId: comment.postId, text: body);
}

Future<bool> editComment({
  required BuildContext context,
  required Comment comment,
}) => writeComment(postId: comment.postId, context: context, comment: comment);

Future<bool> writeComment({
  required BuildContext context,
  required int postId,
  String? text,
  Comment? comment,
}) async {
  bool sent = false;
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => DTextEditor(
        title: Text('#$postId comment'),
        content: text ?? (comment?.body),
        onSubmitted: (text) async {
          final messenger = ScaffoldMessenger.of(context);
          final domain = context.read<Domain>();
          if (text.isNotEmpty) {
            try {
              if (comment == null) {
                await domain.comments.useCreate(postId: postId).mutate(text);
              } else {
                await domain.comments
                    .useUpdate(id: comment.id, postId: postId)
                    .mutate(text);
              }
            } on ClientException {
              return 'Failed to send comment!';
            }
            sent = true;
            messenger.showSnackBar(
              const SnackBar(
                duration: Duration(seconds: 1),
                content: Text('Comment sent!'),
              ),
            );
          }
          return null;
        },
        onClosed: Navigator.of(context).maybePop,
      ),
    ),
  );
  return sent;
}

extension Transitioning on Comment {
  String get hero => getCommentHero(id);
}

String getCommentHero(int id) => 'comment_$id';
