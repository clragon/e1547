import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';

import 'comment.dart';

Future<bool> sendComment(BuildContext context, Post post,
    {String text, Comment comment}) async {
  bool sent = false;
  await Navigator.of(context).push(MaterialPageRoute<Null>(builder: (context) {
    return TextEditor(
      title: '#${post.id} comment',
      content: text ?? (comment != null ? comment.body : null),
      validator: (context, text) async {
        if (text.isNotEmpty) {
          Map response;
          if (text != null) {
            response = await client.postComment(text, post, comment: comment);
          } else {
            response = await client.postComment(text, post);
          }
          if (response['code'] == 200 || response['code'] == 204) {
            sent = true;
            return true;
          } else {
            Scaffold.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 1),
              content: Text(
                  'Failed to send comment: ${response['code']} : ${response['reason']}'),
              behavior: SnackBarBehavior.floating,
            ));
          }
        }
        return false;
      },
    );
  }));
  return sent;
}
