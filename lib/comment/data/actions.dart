import 'package:e1547/client/client.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'comment.dart';

Future<bool> replyComment({
  required BuildContext context,
  required Comment comment,
}) {
  String body = comment.body;
  body = body
      .replaceFirstMapped(
        RegExp(
          r'\[quote\]".*?":/user/show/[0-9]* said:.*\[/quote\]',
          dotAll: true,
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
}) =>
    writeComment(
      postId: comment.postId,
      context: context,
      comment: comment,
    );

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
        onSubmit: (context, text) async {
          final navigator = Navigator.of(context);
          if (text.isNotEmpty) {
            try {
              if (comment == null) {
                await context.read<Client>().postComment(postId, text);
              } else {
                await context
                    .read<Client>()
                    .updateComment(comment.id, postId, text);
              }
              sent = true;
              navigator.maybePop();
            } on DioError {
              return 'Failed to send comment!';
            }
          }
          return null;
        },
      ),
    ),
  );
  return sent;
}

extension Transitioning on Comment {
  String get hero => getCommentHero(id);
}

String getCommentHero(int id) => 'comment_$id';
