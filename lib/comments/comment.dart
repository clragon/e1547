import 'dart:async' show Future;

import 'package:e1547/interface/text_editor.dart';
import 'package:e1547/posts/post.dart' show Post;
import 'package:e1547/services/client.dart' show client;
import 'package:flutter/material.dart';

class Comment {
  Map raw;

  int id;
  int creatorID;
  String creator;
  String body;
  int score;
  String creation;
  String update;

  Comment.fromRaw(this.raw) {
    id = raw['id'] as int;
    creatorID = raw['creator_id'] as int;
    creator = raw['creator_name'] as String;
    body = raw['body'] as String;
    score = raw['score'] as int;
    creation = raw['created_at'] as String;
    update = raw['updated_at'] as String;
  }
}

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
            return Future.value(true);
          } else {
            Scaffold.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 1),
              content: Text(
                  'Failed to send comment: ${response['code']} : ${response['reason']}'),
              behavior: SnackBarBehavior.floating,
            ));
          }
        }
        return Future.value(false);
      },
    );
  }));
  return sent;
}
