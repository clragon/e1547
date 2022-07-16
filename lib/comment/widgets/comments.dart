import 'package:e1547/client/client.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

class CommentsPage extends StatelessWidget {
  final int postId;

  const CommentsPage({required this.postId});

  @override
  Widget build(BuildContext context) {
    return CommentsProvider(
      postId: postId,
      child: Consumer<CommentsController>(
        builder: (context, controller, child) => RefreshableControllerPage(
          appBar: DefaultAppBar(
            leading: const BackButton(),
            title: Text('#$postId comments'),
            actions: const [
              ContextDrawerButton(),
            ],
          ),
          floatingActionButton: context.read<Client>().hasLogin
              ? FloatingActionButton(
                  heroTag: 'float',
                  backgroundColor: Theme.of(context).cardColor,
                  child: Icon(Icons.comment,
                      color: Theme.of(context).iconTheme.color),
                  // TODO: refresh controller?
                  onPressed: () => writeComment(
                    context: context,
                    postId: postId,
                  ),
                )
              : null,
          controller: controller,
          builder: (context) => PagedListView<String, Comment>(
            padding: defaultActionListPadding,
            pagingController: controller,
            builderDelegate: defaultPagedChildBuilderDelegate(
              pagingController: controller,
              itemBuilder: (context, item, index) => CommentProvider(
                id: item.id,
                child: Consumer<CommentController>(
                  builder: (context, controller, child) =>
                      CommentTile(comment: controller),
                ),
              ),
              onEmpty: const Text('No comments'),
              onError: const Text('Failed to load comments'),
            ),
          ),
          endDrawer: ContextDrawer(
            title: const Text('Comments'),
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: controller.orderByOldest,
                builder: (context, value, child) => SwitchListTile(
                  secondary: const Icon(Icons.sort),
                  title: const Text('Comment order'),
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
        ),
      ),
    );
  }
}
