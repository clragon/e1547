import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sliver_tools/sliver_tools.dart';

class PagedStaggeredGridView<PageKeyType, ItemType> extends BoxScrollView {
  final PagingController<PageKeyType, ItemType> pagingController;
  final PagedChildBuilderDelegate<ItemType> builderDelegate;
  final StaggeredTile? Function(int) tileBuilder;
  final bool addAutomaticKeepAlives;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const PagedStaggeredGridView({
    Key? key,
    required this.pagingController,
    required this.builderDelegate,
    required this.crossAxisCount,
    required this.tileBuilder,
    this.addAutomaticKeepAlives = true,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    ScrollController? scrollController,
    ScrollPhysics? physics,
    bool? primary,
    bool shrinkWrap = false,
    EdgeInsets? padding,
  }) : super(
          key: key,
          shrinkWrap: shrinkWrap,
          physics: physics,
          controller: scrollController,
          primary: primary,
          padding: padding,
        );

  @override
  Widget buildChildLayout(BuildContext context) {
    Widget gridBuilder(
      BuildContext context,
      IndexedWidgetBuilder itemBuilder,
      int itemCount,
      WidgetBuilder? appendixBuilder,
    ) {
      return MultiSliver(
        children: [
          SliverStaggeredGrid(
            gridDelegate: SliverStaggeredGridDelegateWithFixedCrossAxisCount(
              staggeredTileBuilder: tileBuilder,
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
            ),
            delegate: SliverChildBuilderDelegate(
              itemBuilder,
              childCount: itemCount,
            ),
            addAutomaticKeepAlives: addAutomaticKeepAlives,
          ),
          if (appendixBuilder != null)
            SliverToBoxAdapter(
              child: appendixBuilder(context),
            ),
        ],
      );
    }

    return PagedSliverBuilder<PageKeyType, ItemType>(
      pagingController: pagingController,
      builderDelegate: builderDelegate,
      completedListingBuilder: gridBuilder,
      loadingListingBuilder: gridBuilder,
      errorListingBuilder: gridBuilder,
    );
  }
}

PagedChildBuilderDelegate<T> defaultPagedChildBuilderDelegate<T>({
  required ItemWidgetBuilder<T> itemBuilder,
  PagingController? pagingController,
  Widget? onLoading,
  Widget? onEmpty,
  Widget? onError,
}) {
  Widget? retryButton() {
    if (pagingController == null) {
      return null;
    }
    return Padding(
      padding: EdgeInsets.all(4),
      child: TextButton(
        onPressed: pagingController.retryLastFailedRequest,
        child: Text('Try again'),
      ),
    );
  }

  return PagedChildBuilderDelegate<T>(
    itemBuilder: itemBuilder,
    firstPageProgressIndicatorBuilder: (context) => Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedCircularProgressIndicator(size: 28),
        Padding(
          padding: EdgeInsets.all(20),
          child: onLoading ?? Text('Loading...'),
        ),
      ],
    ),
    newPageProgressIndicatorBuilder: (context) => Center(
        child: Padding(
      padding: EdgeInsets.all(16),
      child: SizedCircularProgressIndicator(size: 28),
    )),
    noItemsFoundIndicatorBuilder: (context) => IconMessage(
      icon: Icon(Icons.clear),
      title: onEmpty ?? Text('Nothing to see here'),
    ),
    firstPageErrorIndicatorBuilder: (context) => IconMessage(
      icon: Icon(Icons.warning_amber_outlined),
      title: onError ?? Text('Failed to load'),
      action: retryButton(),
    ),
    newPageErrorIndicatorBuilder: (context) => IconMessage(
      direction: Axis.horizontal,
      icon: Icon(Icons.warning_amber_outlined),
      title: onError ?? Text('Failed to load'),
      action: retryButton(),
    ),
  );
}
