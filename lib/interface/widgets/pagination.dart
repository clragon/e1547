import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class PagedChildBuilderRetryButton extends StatelessWidget {
  const PagedChildBuilderRetryButton(this.pagingController);

  final PagingController? pagingController;

  @override
  Widget build(BuildContext context) {
    if (pagingController == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.all(4),
      child: TextButton(
        onPressed: pagingController!.retryLastFailedRequest,
        child: const Text('Try again'),
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
    firstPageProgressIndicatorBuilder: (context) => const Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
        ],
      ),
    ),
    newPageProgressIndicatorBuilder: (context) => const Material(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
    ),
    noItemsFoundIndicatorBuilder: (context) => IconMessage(
      icon: const Icon(Icons.clear),
      title: onEmpty ?? const Text('Nothing to see here'),
    ),
    firstPageErrorIndicatorBuilder: (context) => IconMessage(
      icon: const Icon(Icons.warning_amber_outlined),
      title: onError ?? const Text('Failed to load'),
      action: PagedChildBuilderRetryButton(pagingController),
    ),
    newPageErrorIndicatorBuilder: (context) => IconMessage(
      direction: Axis.horizontal,
      icon: const Icon(Icons.warning_amber_outlined),
      title: onError ?? const Text('Failed to load'),
      action: PagedChildBuilderRetryButton(pagingController),
    ),
  );
}
