import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PostsPageHeadless extends StatefulWidget {
  final PostController controller;

  const PostsPageHeadless({required this.controller});

  @override
  _PostsPageHeadlessState createState() => _PostsPageHeadlessState();
}

class _PostsPageHeadlessState extends State<PostsPageHeadless> {
  @override
  Widget build(BuildContext context) {
    return TileLayoutScope(
      tileBuilder: defaultStaggerTileBuilder(
        (index) {
          PostFile image = widget.controller.itemList![index].sample;
          return Size(image.width.toDouble(), image.height.toDouble());
        },
      ),
      builder: (context, crossAxisCount, tileBuilder) => PagedStaggeredGridView(
        key: joinKeys(['posts', crossAxisCount]),
        physics: BouncingScrollPhysics(),
        showNewPageErrorIndicatorAsGridChild: false,
        showNewPageProgressIndicatorAsGridChild: false,
        showNoMoreItemsIndicatorAsGridChild: false,
        padding: defaultListPadding,
        addAutomaticKeepAlives: false,
        pagingController: widget.controller,
        builderDelegate: defaultPagedChildBuilderDelegate<Post>(
          pagingController: widget.controller,
          onEmpty: Text('No posts'),
          onError: Text('Failed to load posts'),
          itemBuilder: (context, item, index) => PostTile(
            post: item,
            controller: widget.controller,
          ),
        ),
        gridDelegateBuilder: (childCount) =>
            SliverStaggeredGridDelegateWithFixedCrossAxisCount(
          staggeredTileBuilder: tileBuilder,
          crossAxisCount: crossAxisCount,
          staggeredTileCount: widget.controller.itemList?.length,
        ),
      ),
    );
  }
}
