import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/stream.dart';
import 'package:flutter/material.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SubStreamPageController(
      initialPageKey: 1,
      getNextPageKey: (state) => state.nextIntPageKey,
      fetchPage: (pageKey) => ClientRef.of(context).posts.page(page: pageKey),
      builder: (context, state, fetchNextPage) => Scaffold(
        appBar: AppBar(title: const Text('Posts')),
        body: PagedGridView(
          state: state.filter(context),
          fetchNextPage: fetchNextPage,
          builderDelegate: PagedChildBuilderDelegate<Post>(
            itemBuilder: (context, post, index) => InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PostDetailPage(id: post.id),
                ),
              ),
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  Hero(
                    tag: 'post-${post.id}',
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
    );
  }
}
