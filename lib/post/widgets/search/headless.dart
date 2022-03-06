import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
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
    physics: BouncingScrollPhysics(),
    showNewPageErrorIndicatorAsGridChild: false,
    showNewPageProgressIndicatorAsGridChild: false,
    showNoMoreItemsIndicatorAsGridChild: false,
    padding: defaultListPadding,
    addAutomaticKeepAlives: false,
    pagingController: controller,
    builderDelegate: defaultPagedChildBuilderDelegate<Post>(
      pagingController: controller,
      onEmpty: Text('No posts'),
      onError: Text('Failed to load posts'),
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
