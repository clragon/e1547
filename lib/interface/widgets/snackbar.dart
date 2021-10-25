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
  late ScaffoldFeatureController controller;
  controller = ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: LoadingSnackbar<T>(
        items: items,
        process: process,
        timeout: timeout,
        onDone: onDone,
        onProgress: onProgress,
        onFailure: onFailure,
        onCancel: onCancel,
        onFinish: () => controller.close(),
      ),
      duration: Duration(days: 1),
    ),
  );
  return await controller.closed;
}

class LoadingSnackbar<T> extends StatefulWidget {
  final Set<T> items;
  final Duration? timeout;
  final Function? onFinish;
  final String Function(Set<T> items)? onDone;
  final String Function(Set<T> items, int index)? onProgress;
  final String Function(Set<T> items, int index)? onFailure;
  final String Function(Set<T> items, int index)? onCancel;
  final Future<bool> Function(T item) process;

  const LoadingSnackbar({
    required this.items,
    required this.process,
    this.timeout,
    this.onDone,
    this.onProgress,
    this.onFailure,
    this.onCancel,
    this.onFinish,
  });

  @override
  _LoadingSnackbarState<T> createState() => _LoadingSnackbarState<T>();
}

class _LoadingSnackbarState<T> extends State<LoadingSnackbar<T>> {
  bool cancel = false;
  bool failure = false;
  int progress = 0;

  Future<void> run() async {
    for (T item in widget.items) {
      if (await widget.process(item)) {
        await Future.delayed(widget.timeout ?? defaultAnimationDuration);
        setState(() => progress++);
      } else {
        setState(() {
          failure = true;
        });
        break;
      }
      if (cancel) {
        break;
      }
    }
    await Future.delayed(Duration(milliseconds: 1000));
    widget.onFinish?.call();
    return;
  }

  @override
  void initState() {
    super.initState();
    run();
  }

  @override
  Widget build(BuildContext context) {
    bool stopped = progress == widget.items.length || failure || cancel;

    String status() {
      if (failure) {
        return widget.onFailure?.call(widget.items, progress) ??
            'Failed at Item $progress';
      }
      if (cancel) {
        return widget.onCancel?.call(widget.items, progress) ??
            'Cancelled task';
      }
      if (progress == widget.items.length) {
        return widget.onDone?.call(widget.items) ?? 'Done';
      }
      return widget.onProgress?.call(widget.items, progress) ??
          'Item $progress/${widget.items.length}';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              status(),
              overflow: TextOverflow.visible,
            ),
            if (!stopped)
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
                    tween: Tween<double>(begin: 0, end: progress.toDouble()),
                  ),
                ),
              ),
            if (!stopped)
              InkWell(
                child: Text('CANCEL'),
                onTap: () => setState(() => cancel = true),
              ),
          ],
        )
      ],
    );
  }
}
