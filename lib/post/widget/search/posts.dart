import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final domain = DomainRef.of(context);
    final query = domain.posts.usePage();
    return QueryBuilder(
      query: query,
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Posts')),
        body: SubValue(
          create: () => RefreshController(),
          builder: (context, refreshController) => SmartRefresher(
            controller: refreshController,
            onRefresh: () async {
              await query.invalidate();
              refreshController.refreshCompleted();
            },
            child: PagedGridView(
              state: state.paging,
              fetchNextPage: query.getNextPage,
              builderDelegate: PagedChildBuilderDelegate<int>(
                itemBuilder: (context, id, index) => QueryBuilder(
                  query: domain.posts.useGet(id: id, vendored: true),
                  builder: (context, postState) {
                    final post = postState.data ?? FakePost();
                    return InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PostDetailPage(id: post.id),
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: [
                          Hero(
                            tag: post.link,
                            child: Card(
                              child: post.sample != null
                                  ? CachedNetworkImage(
                                      imageUrl: post.sample!,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      Icons.image_not_supported,
                                      size: 60,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                            ),
                          ),
                          if (post.isFavorited)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                color: Colors.black54,
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 24,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                firstPageErrorIndicatorBuilder: (context) => Center(
                  child: Text(
                    state.error?.toString() ?? 'Unknown error',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
              ),
              showNewPageErrorIndicatorAsGridChild: false,
              showNoMoreItemsIndicatorAsGridChild: false,
              showNewPageProgressIndicatorAsGridChild: false,
            ),
          ),
        ),
      ),
    );
  }
}
