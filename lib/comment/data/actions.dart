import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';

import 'comment.dart';

Future<bool> writeComment(BuildContext context, Post post,
    {String? text, Comment? comment}) async {
  bool sent = false;
  await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
    return TextEditor(
      title: '#${post.id} comment',
      content: text ?? (comment != null ? comment.body : null),
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
    );
  }));
  return sent;
}
