import 'package:e1547/comment.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';

class CommentDisplay extends StatelessWidget {
  final Post post;

  CommentDisplay({@required this.post});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: post.comments,
      builder: (BuildContext context, value, Widget child) {
        int count = value ?? 0;
        return CrossFade(
          showChild: count > 0,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlineButton(
                      child: Text('COMMENTS ($count)'),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CommentsPage(post: post),
                        ));
                      },
                    ),
                  )
                ],
              ),
              Divider(),
            ],
          ),
        );
      },
    );
  }
}
