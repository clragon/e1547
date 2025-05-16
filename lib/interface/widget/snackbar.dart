import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

enum LoadingNotificationStatus { loading, cancelled, failed, done }

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
    return switch (status) {
      LoadingNotificationStatus.loading =>
        onProgress?.call(items, progress) ??
            'Item ${progress + 1}/${items.length}',
      LoadingNotificationStatus.cancelled =>
        onCancel?.call(items, progress) ?? 'Cancelled task',
      LoadingNotificationStatus.failed =>
        onFailure?.call(items, progress) ?? 'Failed at Item $progress',
      LoadingNotificationStatus.done => onDone?.call(items) ?? 'Done',
    };
  }

  IconData getStatusIcon(LoadingNotificationStatus status) {
    return switch (status) {
      LoadingNotificationStatus.loading => Icons.download,
      LoadingNotificationStatus.cancelled => Icons.cancel,
      LoadingNotificationStatus.failed => Icons.warning_amber_outlined,
      LoadingNotificationStatus.done => Icons.check,
    };
  }

  LoadingNotificationStatus status = LoadingNotificationStatus.loading;
  final ValueNotifier<int> progress = ValueNotifier<int>(0);

  ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  Color? iconColor =
      (Theme.of(context).snackBarTheme.contentTextStyle ??
              ThemeData(
                brightness:
                    Theme.of(context).brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark,
              ).textTheme.titleMedium)
          ?.color;

  messenger.showSnackBar(
    SnackBar(
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: LoadingNotification(
          messageBuilder: (context, value) => Text(getStatus(status, value)),
          max: items.length,
          progress: progress,
          animationDuration: timeout,
        ),
      ),
      action: SnackBarAction(
        label: 'CANCEL',
        onPressed: () => status = LoadingNotificationStatus.cancelled,
      ),
      duration: const Duration(days: 1),
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

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(getStatusIcon(status), color: iconColor),
          ),
          Flexible(child: Text(getStatus(status, progress.value))),
        ],
      ),
      padding: const EdgeInsets.all(8),
      duration: const Duration(milliseconds: 500),
    ),
  );
}

class LoadingNotification extends StatelessWidget {
  const LoadingNotification({
    super.key,
    required this.messageBuilder,
    required this.progress,
    required this.max,
    this.animationDuration,
  });

  final int max;
  final ValueNotifier<int> progress;
  final Duration? animationDuration;
  final Widget Function(BuildContext context, int progress) messageBuilder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: progress,
      builder:
          (context, value, child) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: messageBuilder(context, value),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: value.toDouble()),
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
              ),
            ],
          ),
    );
  }
}
