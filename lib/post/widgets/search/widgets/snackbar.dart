import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

Future<void> loadingSnackbar({
  required BuildContext context,
  required Set<Post> items,
  required Future<bool> Function(Post post) process,
  Duration? timeout,
}) async {
  late ScaffoldFeatureController controller;
  controller = ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: LoadingSnackbar(
        items: items,
        process: process,
        timeout: timeout,
        onDone: () => controller.close(),
      ),
      duration: Duration(days: 1),
    ),
  );
  return await controller.closed;
}

class LoadingSnackbar extends StatefulWidget {
  final Set<Post> items;
  final Duration? timeout;
  final Function? onDone;
  final Future<bool> Function(Post post) process;

  LoadingSnackbar(
      {required this.items, required this.process, this.timeout, this.onDone});

  @override
  _LoadingSnackbarState createState() => _LoadingSnackbarState();
}

class _LoadingSnackbarState extends State<LoadingSnackbar> {
  bool cancel = false;
  bool failure = false;
  int progress = 0;

  Future<void> run() async {
    for (Post post in widget.items) {
      if (await widget.process(post)) {
        await Future.delayed(widget.timeout ?? defaultAnimationDuration);
        setState(() {
          progress++;
        });
      } else {
        setState(() {
          failure = true;
          progress = widget.items.length;
        });
        break;
      }
      if (cancel) {
        break;
      }
    }
    await Future.delayed(Duration(milliseconds: 600));
    widget.onDone!();
    return;
  }

  @override
  void initState() {
    super.initState();
    run();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              progress < widget.items.length
                  ? 'Post #${widget.items.elementAt(progress).id} ($progress/${widget.items.length})'
                  : failure
                      ? 'Failure'
                      : 'Done',
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
                  tween: Tween<double>(begin: 0, end: progress.toDouble()),
                ),
              ),
            ),
            if (progress < widget.items.length && !failure)
              InkWell(
                child: Text('CANCEL'),
                onTap: () => cancel = true,
              ),
          ],
        )
      ],
    );
  }
}
