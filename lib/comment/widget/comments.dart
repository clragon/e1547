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
      create: (_) => CommentFilter(
        domain: domain,
        value: {
          CommentFilter.postIdFilter.tag: postId,
          CommentFilter.groupByFilter.tag: CommentGroupBy.comment,
          CommentFilter.orderFilter.tag: CommentOrder.id_asc,
        }.toQuery(),
      ),
      keys: (_) => [domain],
      builder: (context, _) {
        final controller = context.watch<CommentFilter>();
        final query = domain.comments.usePage(query: controller.request);
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
                      subtitle: Text(switch (controller.order) {
                        CommentOrder.id_asc => 'oldest first',
                        CommentOrder.id_desc => 'newest first',
                      }),
                      value: controller.order == CommentOrder.id_asc,
                      onChanged: (value) {
                        controller.order = value
                            ? CommentOrder.id_asc
                            : CommentOrder.id_desc;
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
