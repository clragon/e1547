import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CommentsPage extends StatefulWidget {
  final Post post;

  const CommentsPage({required this.post});

  @override
  State createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  late CommentController controller = CommentController(postId: widget.post.id);

  @override
  Widget build(BuildContext context) {
    return RefreshableControllerPage(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('#${widget.post.id} comments'),
        actions: [
          Container(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'float',
        backgroundColor: Theme.of(context).cardColor,
        child: Icon(Icons.comment, color: Theme.of(context).iconTheme.color),
        onPressed: () => writeComment(context: context, post: widget.post),
      ),
      controller: controller,
      builder: (context) => PagedListView(
        padding:
            EdgeInsets.only(top: 8, bottom: kBottomNavigationBarHeight + 24),
        pagingController: controller,
        builderDelegate: defaultPagedChildBuilderDelegate(
          pagingController: controller,
          itemBuilder: (context, Comment item, index) =>
              CommentTile(comment: item, post: widget.post),
          onLoading: Text('Loading comments'),
          onEmpty: Text('No comments'),
          onError: Text('Failed to load comments'),
        ),
      ),
      endDrawer: ContextDrawer(
        title: Text('Comments'),
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: controller.orderByOldest,
            builder: (context, value, child) => SwitchListTile(
              secondary: Icon(Icons.sort),
              title: Text('Comment order'),
              subtitle: Text(value ? 'oldest first' : 'newest first'),
              value: value,
              onChanged: (value) {
                controller.orderByOldest.value = value;
                Navigator.of(context).maybePop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
