import 'package:e1547/comment/comment.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class PostCommentsPage extends StatelessWidget {
  const PostCommentsPage({super.key, required this.postId});

  final int postId;

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    return FilterControllerProvider(
      create: (_) => CommentFilterController(domain: domain),
      keys: (_) => [domain],
      builder: (context, _) {
        final controller = context.watch<CommentFilterController>();
        final query = domain.comments.useByPost(
          postId: postId,
          ascending: controller.orderByOldest,
        );
        return PagedQueryBuilder(
          query: query,
          getItem: (id) => domain.comments.useGet(id: id, vendored: true),
          builder: (context, state) => QueryFilter(
            state: state,
            builder: (context, state) => AdaptiveScaffold(
              appBar: DefaultAppBar(
                title: Text('#$postId comments'),
                actions: const [ContextDrawerButton()],
              ),
              floatingActionButton: domain.hasLogin
                  ? FloatingActionButton(
                      heroTag: 'float',
                      backgroundColor: Theme.of(context).cardColor,
                      child: Icon(
                        Icons.comment,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onPressed: () =>
                          writeComment(context: context, postId: postId),
                    )
                  : null,
              endDrawer: ContextDrawer(
                title: const Text('Comments'),
                children: [
                  Builder(
                    builder: (context) => SwitchListTile(
                      secondary: const Icon(Icons.sort),
                      title: const Text('Comment order'),
                      subtitle: Text(
                        controller.orderByOldest
                            ? 'oldest first'
                            : 'newest first',
                      ),
                      value: controller.orderByOldest,
                      onChanged: (value) {
                        controller.orderByOldest = value;
                        Scaffold.of(context).closeEndDrawer();
                      },
                    ),
                  ),
                ],
              ),
              body: PullToRefresh(
                onRefresh: query.invalidate,
                child: PagedListView<int, Comment>(
                  primary: true,
                  padding: defaultActionListPadding,
                  state: state.paging,
                  fetchNextPage: query.getNextPage,
                  builderDelegate: defaultPagedChildBuilderDelegate(
                    onRetry: query.getNextPage,
                    itemBuilder: (context, comment, index) =>
                        CommentTile(comment: comment),
                    onEmpty: const Text('No comments'),
                    onError: const Text('Failed to load comments'),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
