import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class CommentDisplay extends StatelessWidget {
  const CommentDisplay({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return CrossFade(
      showChild: post.commentCount > 0,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PostCommentsPage(postId: post.id),
                    ),
                  ),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(
                        Theme.of(context).textTheme.bodyText2!.color),
                    overlayColor: MaterialStateProperty.all(
                        Theme.of(context).splashColor),
                  ),
                  child: Text('COMMENTS (${post.commentCount})'),
                ),
              )
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
