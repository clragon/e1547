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
    return TileLayout(
      child: Builder(
        builder: (context) => PagedStaggeredGridView(
          key: joinKeys(['posts', TileLayout.of(context).crossAxisCount]),
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
            staggeredTileBuilder: postStaggeredTileBuilder(
                context, (index) => widget.controller.itemList![index]),
            crossAxisCount: TileLayout.of(context).crossAxisCount,
            staggeredTileCount: widget.controller.itemList?.length,
          ),
        ),
      ),
    );
  }
}
