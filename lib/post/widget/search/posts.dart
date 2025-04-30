import 'package:cached_network_image/cached_network_image.dart';
import 'package:context_plus/context_plus.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/stream/stream.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final client = ClientRef.of(context);
    return SubStreamFuture(
      create: () => client.posts.page(),
      (page) => ClientRef.of(context).posts.page(page: page),
      initialPageParam: 1,
      getNextPageParam: getNextIntPageParam,
      builder: (context, state) => QueryCachePrimer<Post, dynamic, int>(
        result: state,
        generateKey: (post) => client.posts.getKey(post.id),
        child: Scaffold(
          appBar: AppBar(title: const Text('Posts')),
          body: PagedGridView(
            state: state.paging.filter(context),
            fetchNextPage: state.fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate<Post>(
              itemBuilder: (context, post, index) => InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PostDetailPage(id: post.id),
                  ),
                ),
                child: Hero(
                  tag: 'post-${post.id}',
                  child: Card(
                    child: post.sample != null
                        ? CachedNetworkImage(
                            imageUrl: post.sample!,
                            fit: BoxFit.cover,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
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
    );
  }
}
