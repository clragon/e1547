import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

Future<void> loadingSnackbar<T>({
  required BuildContext context,
  required Set<T> items,
  required Future<bool> Function(T item) process,
  String Function(Set<T> items)? onDone,
  String Function(Set<T> items, int index)? onProgress,
  String Function(Set<T> items, int index)? onFailure,
  String Function(Set<T> items, int index)? onCancel,
  Duration? timeout,
}) async {
  ValueNotifier<int> progress = ValueNotifier<int>(0);
  bool cancel = false;
  bool failed = false;

  ScaffoldFeatureController controller =
      ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: LoadingSnackbar<T>(
        items: items,
        timeout: timeout,
        onProgress: onProgress,
        progress: progress,
      ),
      duration: Duration(days: 1),
      action: SnackBarAction(
        label: 'CANCEL',
        onPressed: () => cancel = true,
      ),
    ),
  );

  for (T item in items) {
    if (await process(item)) {
      await Future.delayed(timeout ?? defaultAnimationDuration);
      progress.value++;
    } else {
      failed = true;
      controller.close();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(onFailure?.call(items, progress.value) ??
              'Failed at Item $progress'),
          duration: Duration(seconds: 1),
        ),
      );
      break;
    }
    if (cancel) {
      controller.close();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(onCancel?.call(items, progress.value) ?? 'Cancelled task'),
          duration: Duration(seconds: 1),
        ),
      );
      break;
    }
  }

  if (!failed) {
    controller.close();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(onDone?.call(items) ?? 'Done'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

class LoadingSnackbar<T> extends StatefulWidget {
  final Set<T> items;
  final Duration? timeout;
  final String Function(Set<T> items, int index)? onProgress;
  final ValueNotifier<int> progress;

  const LoadingSnackbar({
    required this.items,
    required this.progress,
    this.onProgress,
    this.timeout,
  });

  @override
  _LoadingSnackbarState<T> createState() => _LoadingSnackbarState<T>();
}

class _LoadingSnackbarState<T> extends State<LoadingSnackbar<T>> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.progress,
      builder: (context, value, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  widget.onProgress
                          ?.call(widget.items, widget.progress.value) ??
                      'Item ${widget.progress.value}/${widget.items.length}',
                  overflow: TextOverflow.visible,
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: TweenAnimationBuilder(
                      duration: widget.timeout ?? defaultAnimationDuration,
                      builder: (context, double value, child) {
                        double indicator = 1 / widget.items.length;
                        if (indicator < 0) {
                          indicator = 1;
                        }
                        indicator = indicator * value;
                        return LinearProgressIndicator(
                          value: indicator,
                          color: Theme.of(context).colorScheme.secondary,
                        );
                      },
                      tween: Tween<double>(
                        begin: 0,
                        end: widget.progress.value.toDouble(),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
