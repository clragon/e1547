import 'package:e1547/interface.dart';
import 'package:e1547/thread.dart';
import 'package:flutter/material.dart';

Future<bool> sendReply(BuildContext context, Thread thread,
    {String text, Reply reply}) async {
  bool sent = false;
  await Navigator.of(context).push(MaterialPageRoute<Null>(builder: (context) {
    return TextEditor(
      title: 'reply to ${thread.title}',
      content: text ?? (reply != null ? reply.body : null),
      validator: (context, text) async {
        if (text.isNotEmpty) {
          Map response;
          if (text != null) {
            // response = await client.postComment(text, post, Reply: reply);
          } else {
            // response = await client.postComment(text, post);
          }
          if (response['code'] == 200 || response['code'] == 204) {
            sent = true;
            return true;
          } else {
            Scaffold.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 1),
              content: Text(
                  'Failed to send reply: ${response['code']} : ${response['reason']}'),
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
