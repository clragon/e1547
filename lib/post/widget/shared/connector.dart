import 'package:e1547/history/history.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

// Rename these to Historian :33
class PostHistoryConnector extends StatelessWidget {
  const PostHistoryConnector({
    super.key,
    required this.post,
    required this.child,
  });

  final Post post;
  final Widget child;

  @override
  Widget build(BuildContext context) => ItemHistoryConnector<Post>(
    item: post,
    getEntry: (context, item) => PostHistoryRequest.item(post: post),
    child: child,
  );
}

class PostPageHistoryConnector extends StatelessWidget {
  const PostPageHistoryConnector({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      // TODO: implement post page history connector
      child;
}
