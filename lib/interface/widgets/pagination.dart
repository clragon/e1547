import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PagedChildBuilderRetryButton extends StatelessWidget {
  final PagingController? pagingController;

  const PagedChildBuilderRetryButton(this.pagingController);

  @override
  Widget build(BuildContext context) {
    if (pagingController == null) {
      return SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.all(4),
      child: TextButton(
        onPressed: pagingController!.retryLastFailedRequest,
        child: Text('Try again'),
      ),
    );
  }
}

PagedChildBuilderDelegate<T> defaultPagedChildBuilderDelegate<T>({
  required ItemWidgetBuilder<T> itemBuilder,
  PagingController? pagingController,
  Widget? onEmpty,
  Widget? onError,
}) {
  return PagedChildBuilderDelegate<T>(
    itemBuilder: itemBuilder,
    firstPageProgressIndicatorBuilder: (context) => Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
        ],
      ),
    ),
    newPageProgressIndicatorBuilder: (context) => Material(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
    ),
    noItemsFoundIndicatorBuilder: (context) => IconMessage(
      icon: Icon(Icons.clear),
      title: onEmpty ?? Text('Nothing to see here'),
    ),
    firstPageErrorIndicatorBuilder: (context) => IconMessage(
      icon: Icon(Icons.warning_amber_outlined),
      title: onError ?? Text('Failed to load'),
      action: PagedChildBuilderRetryButton(pagingController),
    ),
    newPageErrorIndicatorBuilder: (context) => IconMessage(
      direction: Axis.horizontal,
      icon: Icon(Icons.warning_amber_outlined),
      title: onError ?? Text('Failed to load'),
      action: PagedChildBuilderRetryButton(pagingController),
    ),
  );
}
