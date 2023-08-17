import 'package:flutter/material.dart';
import 'package:grouped_list/sliver_grouped_list.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PagedGroupedListView<PageKeyType, ItemType, SortType>
    extends BoxScrollView {
  const PagedGroupedListView({
    super.key,
    required this.pagingController,
    required this.builderDelegate,
    this.shrinkWrapFirstPageIndicators = false,
    required this.groupBy,
    this.groupComparator,
    this.groupSeparatorBuilder,
    this.groupHeaderBuilder,
    this.itemComparator,
    this.order = GroupedListOrder.ASC,
    this.sort = true,
    this.separator = const SizedBox.shrink(),
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    super.cacheExtent,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
  });

  /// Matches [PagedLayoutBuilder.pagingController].
  final PagingController<PageKeyType, ItemType> pagingController;

  /// Matches [PagedLayoutBuilder.builderDelegate].
  final PagedChildBuilderDelegate<ItemType> builderDelegate;

  /// Matches [PagedLayoutBuilder.shrinkWrapFirstPageIndicators].
  final bool shrinkWrapFirstPageIndicators;

  /// Matches [SliverGroupedListView.groupBy].
  final SortType Function(ItemType element) groupBy;

  /// Matches [SliverGroupedListView.groupComparator].
  final int Function(SortType value1, SortType value2)? groupComparator;

  /// Matches [SliverGroupedListView.itemComparator].
  final int Function(ItemType element1, ItemType element2)? itemComparator;

  /// Matches [SliverGroupedListView.groupSeparatorBuilder].
  final Widget Function(SortType value)? groupSeparatorBuilder;

  /// Matches [SliverGroupedListView.groupHeaderBuilder].
  final Widget Function(ItemType element)? groupHeaderBuilder;

  /// Matches [SliverGroupedListView.order].
  final GroupedListOrder order;

  /// Matches [SliverGroupedListView.sort].
  final bool sort;

  /// Matches [SliverGroupedListView.separator].
  final Widget separator;

  @override
  Widget buildChildLayout(BuildContext context) {
    return PagedSliverGroupedListView(
      pagingController: pagingController,
      builderDelegate: builderDelegate,
      shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
      groupBy: groupBy,
      groupComparator: groupComparator,
      groupSeparatorBuilder: groupSeparatorBuilder,
      groupHeaderBuilder: groupHeaderBuilder,
      itemComparator: itemComparator,
      order: order,
      sort: sort,
      separator: separator,
    );
  }
}

class PagedSliverGroupedListView<PageKeyType, ItemType, SortType>
    extends StatelessWidget {
  const PagedSliverGroupedListView({
    super.key,
    required this.pagingController,
    required this.builderDelegate,
    this.shrinkWrapFirstPageIndicators = false,
    required this.groupBy,
    this.groupComparator,
    this.groupSeparatorBuilder,
    this.groupHeaderBuilder,
    this.itemComparator,
    this.order = GroupedListOrder.ASC,
    this.sort = true,
    this.separator = const SizedBox.shrink(),
  });

  /// Matches [PagedLayoutBuilder.pagingController].
  final PagingController<PageKeyType, ItemType> pagingController;

  /// Matches [PagedLayoutBuilder.builderDelegate].
  final PagedChildBuilderDelegate<ItemType> builderDelegate;

  /// Matches [PagedLayoutBuilder.shrinkWrapFirstPageIndicators].
  final bool shrinkWrapFirstPageIndicators;

  /// Matches [SliverGroupedListView.groupBy].
  final SortType Function(ItemType element) groupBy;

  /// Matches [SliverGroupedListView.groupComparator].
  final int Function(SortType value1, SortType value2)? groupComparator;

  /// Matches [SliverGroupedListView.itemComparator].
  final int Function(ItemType element1, ItemType element2)? itemComparator;

  /// Matches [SliverGroupedListView.groupSeparatorBuilder].
  final Widget Function(SortType value)? groupSeparatorBuilder;

  /// Matches [SliverGroupedListView.groupHeaderBuilder].
  final Widget Function(ItemType element)? groupHeaderBuilder;

  /// Matches [SliverGroupedListView.order].
  final GroupedListOrder order;

  /// Matches [SliverGroupedListView.sort].
  final bool sort;

  /// Matches [SliverGroupedListView.separator].
  final Widget separator;

  @override
  Widget build(BuildContext context) {
    Widget buildLayout(
      IndexedWidgetBuilder itemBuilder,
      int itemCount, {
      WidgetBuilder? statusIndicatorBuilder,
    }) =>
        SliverMainAxisGroup(
          slivers: [
            SliverGroupedListView<ItemType, SortType>(
              key: key,
              elements: pagingController.itemList!,
              groupBy: groupBy,
              groupComparator: groupComparator,
              groupSeparatorBuilder: groupSeparatorBuilder,
              groupHeaderBuilder: groupHeaderBuilder,
              indexedItemBuilder: (context, item, index) =>
                  itemBuilder(context, index),
              itemComparator: itemComparator,
              order: order,
              sort: sort,
              separator: separator,
            ),
            if (statusIndicatorBuilder != null)
              SliverToBoxAdapter(
                child: statusIndicatorBuilder(context),
              )
          ],
        );

    return PagedLayoutBuilder<PageKeyType, ItemType>(
      layoutProtocol: PagedLayoutProtocol.sliver,
      pagingController: pagingController,
      builderDelegate: builderDelegate,
      shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
      completedListingBuilder: (
        context,
        itemBuilder,
        itemCount,
        noMoreItemsIndicatorBuilder,
      ) =>
          buildLayout(
        itemBuilder,
        itemCount,
        statusIndicatorBuilder: noMoreItemsIndicatorBuilder,
      ),
      loadingListingBuilder: (
        context,
        itemBuilder,
        itemCount,
        progressIndicatorBuilder,
      ) =>
          buildLayout(
        itemBuilder,
        itemCount,
        statusIndicatorBuilder: progressIndicatorBuilder,
      ),
      errorListingBuilder: (
        context,
        itemBuilder,
        itemCount,
        errorIndicatorBuilder,
      ) =>
          buildLayout(
        itemBuilder,
        itemCount,
        statusIndicatorBuilder: errorIndicatorBuilder,
      ),
    );
  }
}
