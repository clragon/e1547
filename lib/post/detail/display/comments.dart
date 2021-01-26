import 'package:e1547/comment.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';

class CommentDisplay extends StatefulWidget {
  final Post post;

  const CommentDisplay({@required this.post});

  @override
  _CommentDisplayState createState() => _CommentDisplayState();
}

class _CommentDisplayState extends State<CommentDisplay> {
  @override
  Widget build(BuildContext context) {
    int count = widget.post.comments.value ?? 0;
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
                      builder: (context) => CommentsPage(post: widget.post),
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
  }
}
