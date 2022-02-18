import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/widgets.dart';

class CommentLoadingPage extends StatefulWidget {
  final int id;

  const CommentLoadingPage(this.id);

  @override
  _CommentLoadingPageState createState() => _CommentLoadingPageState();
}

class _CommentLoadingPageState extends State<CommentLoadingPage> {
  late Future<Comment> comment = client.comment(widget.id);

  @override
  Widget build(BuildContext context) {
    return FuturePageLoader<Comment>(
      future: comment,
      builder: (context, value) => CommentsPage(postId: value.postId),
      title: Text('Comment #${widget.id}'),
      onError: Text('Failed to load comment'),
      onEmpty: Text('Comment not found'),
    );
  }
}
