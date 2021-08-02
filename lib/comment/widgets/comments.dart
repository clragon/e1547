import 'package:e1547/comment.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CommentsPage extends StatefulWidget {
  final Post post;

  CommentsPage({required this.post});

  @override
  State createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> with UpdateMixin {
  late CommentController controller;

  @override
  void initState() {
    super.initState();
    controller = CommentController(postId: widget.post.id);
  }

  @override
  Widget build(BuildContext context) {
    Widget floatingActionButton() {
      return FloatingActionButton(
        heroTag: 'float',
        backgroundColor: Theme.of(context).cardColor,
        child: Icon(Icons.comment, color: Theme.of(context).iconTheme.color),
        onPressed: () => writeComment(context: context, post: widget.post),
      );
    }

    return RefreshableControllerPage(
      appBar: AppBar(title: Text('#${widget.post.id} comments')),
      floatingActionButton: floatingActionButton(),
      controller: controller,
      builder: (context) {
        return PagedListView(
          padding: EdgeInsets.only(top: 8),
          pagingController: controller,
          builderDelegate: defaultPagedChildBuilderDelegate(
            itemBuilder: (context, Comment item, index) =>
                CommentTile(comment: item, post: widget.post),
            onLoading: Text('Loading comments'),
            onEmpty: Text('No comments'),
            onError: Text('Failed to load comments'),
          ),
        );
      },
    );
  }
}
