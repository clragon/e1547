import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

enum PostDisplayType {
  grid,
  comic,
  timeline,
}

// These need to be functions because SmartRefresher needs the ScrollView as direct child
Widget postDisplay({
  required BuildContext context,
  required PostsController controller,
  PostDisplayType displayType = PostDisplayType.grid,
}) {
  switch (displayType) {
    case PostDisplayType.grid:
      return postGrid(context: context, controller: controller);
    case PostDisplayType.comic:
      return postComic(context: context, controller: controller);
    case PostDisplayType.timeline:
      return postTimeline(context: context, controller: controller);
  }
}

Widget postGrid({
  required BuildContext context,
  required PostsController controller,
}) {
  PagedChildBuilderDelegate<Post> buildBuilderDelegate(
          ItemWidgetBuilder<Post> itemBuilder) =>
      defaultPagedChildBuilderDelegate<Post>(
        pagingController: controller,
        onEmpty: const Text('No posts'),
        onError: const Text('Failed to load posts'),
        itemBuilder: itemBuilder,
      );

  Widget itemBuilder(context, item, index) => LowResCacheSizeProvider(
        size: TileLayout.of(context).tileSize * 2,
        child: PostTile(post: item),
      );

  switch (TileLayout.of(context).stagger) {
    case GridQuilt.square:
      return PagedGridView<int, Post>(
        primary: true,
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
        primary: true,
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

Widget postComic({
  required BuildContext context,
  required PostsController controller,
}) {
  return PagedListView(
    primary: true,
    padding: defaultActionListPadding
        .add(LimitedWidthLayout.maybeOf(context)?.padding ?? EdgeInsets.zero),
    pagingController: controller,
    builderDelegate: defaultPagedChildBuilderDelegate<Post>(
      pagingController: controller,
      onEmpty: const Text('No posts'),
      onError: const Text('Failed to load posts'),
      itemBuilder: (context, item, index) => LowResCacheSizeProvider(
        size: 800,
        child: PostComicTile(post: item),
      ),
    ),
  );
}

Widget postTimeline({
  required BuildContext context,
  required PostsController controller,
}) {
  return PagedListView(
    primary: true,
    padding: defaultActionListPadding
        .add(LimitedWidthLayout.maybeOf(context)?.padding ?? EdgeInsets.zero),
    pagingController: controller,
    builderDelegate: defaultPagedChildBuilderDelegate<Post>(
      pagingController: controller,
      onEmpty: const Text('No posts'),
      onError: const Text('Failed to load posts'),
      itemBuilder: (context, item, index) => LowResCacheSizeProvider(
        size: 800,
        child: PostFeedTile(post: item),
      ),
    ),
  );
}
