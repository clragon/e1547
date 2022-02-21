import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CommentsPage extends StatefulWidget {
  final int postId;

  const CommentsPage({required this.postId});

  @override
  State createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  late CommentController controller = CommentController(postId: widget.postId);

  @override
  Widget build(BuildContext context) {
    return RefreshableControllerPage(
      appBar: DefaultAppBar(
        leading: BackButton(),
        title: Text('#${widget.postId} comments'),
        actions: [
          ContextDrawerButton(),
        ],
      ),
      floatingActionButton: client.hasLogin
          ? FloatingActionButton(
              heroTag: 'float',
              backgroundColor: Theme.of(context).cardColor,
              child:
                  Icon(Icons.comment, color: Theme.of(context).iconTheme.color),
              onPressed: () => writeComment(
                context: context,
                postId: widget.postId,
              ),
            )
          : null,
      controller: controller,
      builder: (context) => PagedListView(
        padding: defaultActionListPadding.copyWith(top: 8),
        pagingController: controller,
        builderDelegate: defaultPagedChildBuilderDelegate(
          pagingController: controller,
          itemBuilder: (context, Comment item, index) => CommentTile(
            comment: item,
            controller: controller,
          ),
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
