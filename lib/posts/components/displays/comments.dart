import 'package:e1547/comments/comments_page.dart';
import 'package:e1547/interface/cross_fade.dart';
import 'package:e1547/posts/post.dart';
import 'package:flutter/material.dart';

class CommentDisplay extends StatefulWidget {
  final Post post;

  const CommentDisplay(this.post);

  @override
  _CommentDisplayState createState() => _CommentDisplayState();
}

class _CommentDisplayState extends State<CommentDisplay> {
  @override
  void initState() {
    super.initState();
    widget.post.comments.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    widget.post.comments.removeListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return CrossFade(
      showChild: widget.post.comments.value > 0,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: OutlineButton(
                  child: Text('COMMENTS (${widget.post.comments.value})'),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute<Null>(
                      settings: RouteSettings(name: 'comments'),
                      builder: (context) => CommentsWidget(widget.post),
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
