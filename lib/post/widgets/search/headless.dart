import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PostGrid extends StatelessWidget {
  final PostController controller;

  const PostGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    return postGrid(context, controller);
  }
}

// This is needed because SmartRefresher needs the ScrollView as direct child
Widget postGrid(BuildContext context, PostController controller) {
  return PagedStaggeredGridView(
    key: joinKeys(['posts', TileLayout.of(context).crossAxisCount]),
    showNewPageErrorIndicatorAsGridChild: false,
    showNewPageProgressIndicatorAsGridChild: false,
    showNoMoreItemsIndicatorAsGridChild: false,
    padding: defaultListPadding,
    addAutomaticKeepAlives: false,
    pagingController: controller,
    builderDelegate: defaultPagedChildBuilderDelegate<Post>(
      pagingController: controller,
      onEmpty: const Text('No posts'),
      onError: const Text('Failed to load posts'),
      itemBuilder: (context, item, index) => PostTile(
        post: item,
        controller: controller,
      ),
    ),
    gridDelegateBuilder: (childCount) =>
        SliverStaggeredGridDelegateWithFixedCrossAxisCount(
      staggeredTileBuilder: postStaggeredTileBuilder(
          context, (index) => controller.itemList![index]),
      crossAxisCount: TileLayout.of(context).crossAxisCount,
      staggeredTileCount: controller.itemList?.length,
    ),
  );
}

IndexedStaggeredTileBuilder postStaggeredTileBuilder(
    BuildContext context, Post Function(int index) postFromIndex) {
  return (int index) {
    TileLayoutData layoutData = TileLayout.of(context);
    PostFile image = postFromIndex(index).sample;

    Size size = Size(image.width.toDouble(), image.height.toDouble());
    double widthRatio = size.width / size.height;
    double heightRatio = size.height / size.width;

    switch (layoutData.stagger) {
      case GridQuilt.square:
        return StaggeredTile.count(1, 1 * layoutData.tileHeightFactor);
      case GridQuilt.vertical:
        return StaggeredTile.count(1, heightRatio);
      case GridQuilt.omni:
        if (layoutData.crossAxisCount == 1) {
          return StaggeredTile.count(1, heightRatio);
        } else {
          return StaggeredTile.count(notZero(widthRatio),
              notZero(heightRatio) * layoutData.tileHeightFactor);
        }
    }
  };
}
