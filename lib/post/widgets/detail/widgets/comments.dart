import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class CommentDisplay extends StatelessWidget {
  final Post post;
  final PostController? controller;

  const CommentDisplay({required this.post, this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller]),
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
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CommentsPage(postId: post.id),
                          ),
                        );
                      },
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
