import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

import 'comment.dart';

Future<bool> replyComment(
    {required BuildContext context,
    required Post post,
    required Comment comment}) {
  String body = comment.body;
  body = body
      .replaceFirstMapped(
          RegExp(r'\[quote\]".*?":/user/show/[0-9]* said:.*\[\/quote\]',
              dotAll: true),
          (match) => '')
      .trim();
  body =
      '[quote]"${comment.creatorName}":/users/${comment.creatorId} said:\n$body[/quote]\n';
  return writeComment(context: context, post: post, text: body);
}

Future<bool> editComment(
        {required BuildContext context,
        required Post post,
        required Comment comment}) =>
    writeComment(context: context, post: post, comment: comment);

Future<bool> writeComment(
    {required BuildContext context,
    required Post post,
    String? text,
    Comment? comment}) async {
  bool sent = false;
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => TextEditor(
        title: '#${post.id} comment',
        content: text ?? (comment?.body),
        validator: (context, text) async {
          if (text.isNotEmpty) {
            try {
              if (comment != null) {
                await client.postComment(text, post, comment: comment);
              } else {
                await client.postComment(text, post);
              }
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
