import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import 'widgets/mason.dart';

class PostGrid extends StatelessWidget {
  const PostGrid({required this.controller});

  final PostsController controller;

  @override
  Widget build(BuildContext context) => postGrid(context, controller);
}

// This is needed because SmartRefresher needs the ScrollView as direct child
Widget postGrid(BuildContext context, PostsController controller) {
  PagedChildBuilderDelegate<Post> buildBuilderDelegate(
          ItemWidgetBuilder<Post> itemBuilder) =>
      defaultPagedChildBuilderDelegate<Post>(
        pagingController: controller,
        onEmpty: const Text('No posts'),
        onError: const Text('Failed to load posts'),
        itemBuilder: itemBuilder,
      );

  Widget itemBuilder(context, item, index) => PostProvider(
        id: item.id,
        parent: controller,
        child: Consumer<PostController>(
          builder: (context, post, child) {
            int cacheSize = TileLayout.of(context).tileSize * 2;
            return SampleCacheSizeProvider(
              size: cacheSize,
              child: PostTile(
                controller: post,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SampleCacheSizeProvider(
                      size: cacheSize,
                      child: PostDetailConnector(
                        controller: controller,
                        child: PostDetailGallery(
                          controller: controller,
                          initialPage: index,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );

  switch (TileLayout.of(context).stagger) {
    case GridQuilt.square:
      return PagedGridView<int, Post>(
        showNewPageErrorIndicatorAsGridChild: false,
        showNewPageProgressIndicatorAsGridChild: false,
        showNoMoreItemsIndicatorAsGridChild: false,
        padding: defaultListPadding,
        pagingController: controller,
        builderDelegate: buildBuilderDelegate(itemBuilder),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: TileLayout.of(context).crossAxisCount,
          childAspectRatio: 1 / TileLayout.of(context).tileHeightFactor,
        ),
      );
    case GridQuilt.vertical:
      return PagedMasonryGridView<int, Post>.count(
        showNewPageErrorIndicatorAsGridChild: false,
        showNewPageProgressIndicatorAsGridChild: false,
        showNoMoreItemsIndicatorAsGridChild: false,
        padding: defaultListPadding,
        pagingController: controller,
        builderDelegate: buildBuilderDelegate(
          (context, item, index) => AspectRatio(
            aspectRatio: 1 / (item.sample.height / item.sample.width),
            child: itemBuilder(context, item, index),
          ),
        ),
        crossAxisCount: TileLayout.of(context).crossAxisCount,
      );
  }
}
