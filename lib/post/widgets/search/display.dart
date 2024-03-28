/// Why does this file contain only Widget functions, and not Widget classes?
///
/// I am glad you asked. This is actually a hack to solve the annoying problem
/// that is introduced by the pull_to_refresh package. The package requires
/// the ScrollView to be the direct child of the SmartRefresher widget. This
/// means we cannot introduce any intermediary classes between the ScrollView
/// and the SmartRefresher. This issue also causes a lot of other weird design
/// choices, but alas. One day, we'll switch to custom scroll views.
library post_display_widgets;

import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

enum PostDisplayType {
  grid,
  comic,
  timeline,
}

// These need to be functions because SmartRefresher needs the ScrollView as direct child
Widget postDisplay({
  required BuildContext context,
  required PostController controller,
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
  required PostController controller,
}) {
  PagedChildBuilderDelegate<Post> buildBuilderDelegate(
          ItemWidgetBuilder<Post> itemBuilder) =>
      defaultPagedChildBuilderDelegate<Post>(
        pagingController: controller.paging,
        onEmpty: const Text('No posts'),
        onError: const Text('Failed to load posts'),
        itemBuilder: itemBuilder,
      );

  Widget itemBuilder(context, item, index) => ImageCacheSizeProvider(
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
        pagingController: controller.paging,
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
        pagingController: controller.paging,
        builderDelegate: buildBuilderDelegate(
          (context, item, index) => AspectRatio(
            aspectRatio: 1 / (item.height / item.width),
            child: itemBuilder(context, item, index),
          ),
        ),
        crossAxisCount: TileLayout.of(context).crossAxisCount,
      );
  }
}

Widget postComic({
  required BuildContext context,
  required PostController controller,
}) {
  return PagedListView(
    primary: true,
    padding: defaultActionListPadding
        .add(LimitedWidthLayout.maybeOf(context)?.padding ?? EdgeInsets.zero),
    pagingController: controller.paging,
    builderDelegate: defaultPagedChildBuilderDelegate<Post>(
      pagingController: controller.paging,
      onEmpty: const Text('No posts'),
      onError: const Text('Failed to load posts'),
      itemBuilder: (context, item, index) => ImageCacheSizeProvider(
        size: 800,
        child: PostComicTile(post: item),
      ),
    ),
  );
}

Widget postTimeline({
  required BuildContext context,
  required PostController controller,
}) {
  return PagedListView(
    primary: true,
    padding: defaultActionListPadding
        .add(LimitedWidthLayout.maybeOf(context)?.padding ?? EdgeInsets.zero),
    pagingController: controller.paging,
    builderDelegate: defaultPagedChildBuilderDelegate<Post>(
      pagingController: controller.paging,
      onEmpty: const Text('No posts'),
      onError: const Text('Failed to load posts'),
      itemBuilder: (context, item, index) => ImageCacheSizeProvider(
        size: 800,
        child: PostFeedTile(post: item),
      ),
    ),
  );
}
