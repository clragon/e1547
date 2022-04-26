import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

enum LoadingNotificationStatus {
  loading,
  cancelled,
  failed,
  done,
}

Future<void> loadingNotification<T>({
  required BuildContext context,
  required Set<T> items,
  required Future<bool> Function(T item) process,
  String Function(Set<T> items, int index)? onProgress,
  String Function(Set<T> items, int index)? onFailure,
  String Function(Set<T> items, int index)? onCancel,
  String Function(Set<T> items)? onDone,
  Duration? timeout,
  Widget? icon,
}) async {
  String getStatus(LoadingNotificationStatus status, int progress) {
    switch (status) {
      case LoadingNotificationStatus.loading:
        return onProgress?.call(items, progress) ??
            'Item ${progress + 1}/${items.length}';
      case LoadingNotificationStatus.cancelled:
        return onCancel?.call(items, progress) ?? 'Cancelled task';
      case LoadingNotificationStatus.failed:
        return onFailure?.call(items, progress) ?? 'Failed at Item $progress';
      case LoadingNotificationStatus.done:
        return onDone?.call(items) ?? 'Done';
    }
  }

  IconData getStatusIcon(LoadingNotificationStatus status) {
    switch (status) {
      case LoadingNotificationStatus.loading:
        return Icons.download;
      case LoadingNotificationStatus.cancelled:
        return Icons.cancel;
      case LoadingNotificationStatus.failed:
        return Icons.warning_amber_outlined;
      case LoadingNotificationStatus.done:
        return Icons.check;
    }
  }

  LoadingNotificationStatus status = LoadingNotificationStatus.loading;
  final ValueNotifier<int> progress = ValueNotifier(0);

  ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

  messenger.showMaterialBanner(
    MaterialBanner(
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: LoadingNotification(
          messageBuilder: (context, value) => Text(getStatus(status, value)),
          max: items.length,
          progress: progress,
          animationDuration: timeout,
        ),
      ),
      leading: icon,
      padding: const EdgeInsets.all(8),
      leadingPadding: const EdgeInsets.all(8),
      actions: [
        TextButton(
          onPressed: () => status = LoadingNotificationStatus.cancelled,
          child: const Text('CANCEL'),
        ),
      ],
    ),
  );

  for (T item in items) {
    if (await process(item)) {
      await Future.delayed(timeout ?? defaultAnimationDuration);
      if (progress.value < items.length - 1) {
        progress.value++;
      }
    } else {
      status = LoadingNotificationStatus.failed;
      break;
    }
    if (status == LoadingNotificationStatus.cancelled) {
      break;
    }
  }

  if (status == LoadingNotificationStatus.loading) {
    status = LoadingNotificationStatus.done;
  }

  messenger.hideCurrentMaterialBanner();
  messenger.showMaterialBanner(
    MaterialBanner(
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(getStatus(status, progress.value)),
      ),
      leading: Icon(getStatusIcon(status)),
      padding: const EdgeInsets.all(8),
      leadingPadding: const EdgeInsets.all(8),
      actions: [
        TextButton(
          onPressed: messenger.hideCurrentMaterialBanner,
          child: const Text('DISMISS'),
        ),
      ],
    ),
  );

  await Future.delayed(const Duration(seconds: 2));
  messenger.hideCurrentMaterialBanner();
}

class LoadingNotification extends StatelessWidget {
  final int max;
  final ValueNotifier<int> progress;
  final Duration? animationDuration;
  final Widget Function(BuildContext context, int progress) messageBuilder;

  const LoadingNotification({
    required this.messageBuilder,
    required this.progress,
    required this.max,
    this.animationDuration,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: progress,
      builder: (context, value, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: messageBuilder(context, value),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: value.toDouble(),
              ),
              duration: animationDuration ?? defaultAnimationDuration,
              builder: (context, value, child) {
                double? indicator = 1 / max;
                if (indicator < 0) {
                  indicator = 1;
                }
                indicator = indicator * value;
                if (indicator == 0) {
                  indicator = null;
                }
                return LinearProgressIndicator(
                  value: indicator,
                  color: Theme.of(context).colorScheme.secondary,
                );
              },
            )
          ],
        );
      },
    );
  }
}
