import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class PagedChildBuilderRetryButton extends StatelessWidget {
  const PagedChildBuilderRetryButton(this.onRetry, {super.key});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (onRetry == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.all(4),
      child: TextButton(onPressed: onRetry, child: const Text('Try again')),
    );
  }
}

PagedChildBuilderDelegate<T> defaultPagedChildBuilderDelegate<T>({
  required ItemWidgetBuilder<T> itemBuilder,
  VoidCallback? onRetry,
  Widget? onEmpty,
  Widget? onError,
  Widget Function(BuildContext context, Widget child)? pageBuilder,
}) {
  pageBuilder ??= (context, child) => child;
  return PagedChildBuilderDelegate<T>(
    itemBuilder: itemBuilder,
    firstPageProgressIndicatorBuilder: (context) => pageBuilder!(
      context,
      const Material(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircularProgressIndicator()],
        ),
      ),
    ),
    newPageProgressIndicatorBuilder: (context) => pageBuilder!(
      context,
      const Material(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    ),
    noItemsFoundIndicatorBuilder: (context) => pageBuilder!(
      context,
      IconMessage(
        icon: const Icon(Icons.clear),
        title: onEmpty ?? const Text('Nothing to see here'),
      ),
    ),
    firstPageErrorIndicatorBuilder: (context) => pageBuilder!(
      context,
      IconMessage(
        icon: const Icon(Icons.warning_amber_outlined),
        title: onError ?? const Text('Failed to load'),
        action: PagedChildBuilderRetryButton(onRetry),
      ),
    ),
    newPageErrorIndicatorBuilder: (context) => pageBuilder!(
      context,
      IconMessage(
        direction: Axis.horizontal,
        icon: const Icon(Icons.warning_amber_outlined),
        title: onError ?? const Text('Failed to load'),
        action: PagedChildBuilderRetryButton(onRetry),
      ),
    ),
  );
}
