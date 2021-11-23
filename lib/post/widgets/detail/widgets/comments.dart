import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class CommentDisplay extends StatelessWidget {
  final Post post;

  const CommentDisplay({required this.post});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: post,
      builder: (context, child) {
        int count = post.commentCount;
        return CrossFade(
          showChild: count > 0,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      child: Text('COMMENTS ($count)'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CommentsPage(postId: post.id),
                          ),
                        );
                      },
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                            Theme.of(context).textTheme.bodyText1!.color),
                        overlayColor: MaterialStateProperty.all(
                            Theme.of(context).splashColor),
                      ),
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
