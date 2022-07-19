import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

class PostGrid extends StatelessWidget {
  final PostsController controller;

  const PostGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    return postGrid(context, controller);
  }
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
          builder: (context, post, child) => PostTile(
            post: post,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PostDetailConnector(
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
          (context, item, index) {
            double aspectRatio = 1;
            if (item.sample.has) {
              aspectRatio = 1 / (item.sample.height / item.sample.width);
            }
            return AspectRatio(
              aspectRatio: aspectRatio,
              child: itemBuilder(context, item, index),
            );
          },
        ),
        crossAxisCount: TileLayout.of(context).crossAxisCount,
      );
  }
}
