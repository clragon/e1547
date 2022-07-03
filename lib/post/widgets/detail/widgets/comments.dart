import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class CommentDisplay extends StatelessWidget {
  final PostController post;

  const CommentDisplay({required this.post});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([post]),
      builder: (context, child) {
        int count = post.value.commentCount;
        return CrossFade(
          showChild: count > 0,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              CommentsPage(postId: post.value.id),
                        ),
                      ),
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(
                            Theme.of(context).textTheme.bodyText2!.color),
                        overlayColor: MaterialStateProperty.all(
                            Theme.of(context).splashColor),
                      ),
                      child: Text('COMMENTS ($count)'),
                    ),
                  )
                ],
              ),
              const Divider(),
            ],
          ),
        );
      },
    );
  }
}
