import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:flutter/widgets.dart';

class CommentLoadingPage extends StatefulWidget {
  const CommentLoadingPage(this.id, {super.key});

  final int id;

  @override
  State<CommentLoadingPage> createState() => _CommentLoadingPageState();
}

class _CommentLoadingPageState extends State<CommentLoadingPage> {
  late Future<Comment> comment =
      context.read<Client>().comments.get(id: widget.id);

  @override
  Widget build(BuildContext context) {
    return FutureLoadingPage<Comment>(
      future: comment,
      builder: (context, value) => PostCommentsPage(postId: value.postId),
      title: Text('Comment #${widget.id}'),
      onError: const Text('Failed to load comment'),
      onEmpty: const Text('Comment not found'),
    );
  }
}
