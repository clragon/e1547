import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

enum LoadingNotificationStatus {
  loading,
  cancelled,
  failed,
  done,
}

class LoadingNotificationController extends ChangeNotifier {
  LoadingNotificationStatus _status = LoadingNotificationStatus.loading;

  LoadingNotificationStatus get status => _status;

  set status(value) {
    _status = value;
    notifyListeners();
  }

  int _progress = 0;

  int get progress => _progress;

  set progress(int value) {
    _progress = value;
    notifyListeners();
  }
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
  ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  LoadingNotificationController controller = LoadingNotificationController();

  messenger.showMaterialBanner(
    MaterialBanner(
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: LoadingNotification<T>(
          items: items,
          controller: controller,
          onProgress: onProgress,
          onFailure: onFailure,
          onCancel: onCancel,
          onDone: onDone,
          timeout: timeout,
          icon: icon,
        ),
      ),
      leading: icon,
      padding: EdgeInsets.all(8),
      leadingPadding: EdgeInsets.all(8),
      backgroundColor: Theme.of(context).canvasColor,
      actions: [
        TextButton(
          onPressed: () =>
              controller.status = LoadingNotificationStatus.cancelled,
          child: Text('CANCEL'),
        ),
      ],
    ),
  );

  for (T item in items) {
    if (await process(item)) {
      await Future.delayed(timeout ?? defaultAnimationDuration);
      if (controller.progress < items.length - 1) {
        controller.progress++;
      }
    } else {
      controller.status = LoadingNotificationStatus.failed;
      break;
    }
    if (controller.status == LoadingNotificationStatus.cancelled) {
      break;
    }
  }
  if (controller.status == LoadingNotificationStatus.loading) {
    controller.status = LoadingNotificationStatus.done;
  }

  await Future.delayed(Duration(milliseconds: 1000));
  messenger.hideCurrentMaterialBanner();
}

class LoadingNotification<T> extends StatelessWidget {
  final LoadingNotificationController controller;
  final Set<T> items;
  final String Function(Set<T> items)? onDone;
  final String Function(Set<T> items, int index)? onProgress;
  final String Function(Set<T> items, int index)? onFailure;
  final String Function(Set<T> items, int index)? onCancel;
  final Duration? timeout;
  final Widget? icon;

  const LoadingNotification({
    required this.controller,
    required this.items,
    this.onDone,
    this.onProgress,
    this.onFailure,
    this.onCancel,
    this.icon,
    this.timeout,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        String getStatus() {
          switch (controller.status) {
            case LoadingNotificationStatus.loading:
              return onProgress?.call(items, controller.progress) ??
                  'Item ${controller.progress + 1}/${items.length}';
            case LoadingNotificationStatus.cancelled:
              return onCancel?.call(items, controller.progress) ??
                  'Cancelled task';
            case LoadingNotificationStatus.failed:
              return onFailure?.call(items, controller.progress) ??
                  'Failed at Item ${controller.progress}';
            case LoadingNotificationStatus.done:
              return onDone?.call(items) ?? 'Done';
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                getStatus(),
                overflow: TextOverflow.visible,
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: controller.status != LoadingNotificationStatus.loading
                    ? items.length.toDouble()
                    : controller.progress.toDouble(),
              ),
              duration: timeout ?? defaultAnimationDuration,
              builder: (context, value, child) {
                double? indicator = 1 / items.length;
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
        );
      },
    );
  }
}
