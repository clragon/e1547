import 'package:e1547/post.dart';
import 'package:flutter/material.dart';

Future<void> loadingSnackbar({
  @required BuildContext context,
  @required Set<Post> items,
  @required Future<bool> Function(Post post) process,
  Duration timeout,
}) async {
  ScaffoldFeatureController controller;
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
  final Duration timeout;
  final Function onDone;
  final Future<bool> Function(Post post) process;

  LoadingSnackbar(
      {@required this.items,
      @required this.process,
      this.timeout,
      this.onDone});

  @override
  _LoadingSnackbarState createState() => _LoadingSnackbarState();
}

class _LoadingSnackbarState extends State<LoadingSnackbar> {
  bool cancel = false;
  bool failure = false;
  ValueNotifier<int> progress = ValueNotifier<int>(0);

  Future<void> run() async {
    for (Post post in widget.items) {
      if (await widget.process(post)) {
        await Future.delayed(widget.timeout ?? Duration(milliseconds: 200));
        progress.value++;
        setState(() {});
      } else {
        failure = true;
        progress.value = widget.items.length;
        setState(() {});
        break;
      }
      if (cancel) {
        break;
      }
    }
    await Future.delayed(Duration(milliseconds: 600));
    widget.onDone();
    setState(() {});
    return;
  }

  @override
  void initState() {
    super.initState();
    run();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: progress,
        builder: (BuildContext context, int value, Widget child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    value == widget.items.length
                        ? failure
                            ? 'Failure'
                            : 'Done'
                        : 'Post #${widget.items.elementAt(value).id} ($value/${widget.items.length})',
                    overflow: TextOverflow.visible,
                  ),
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: TweenAnimationBuilder(
                        duration: widget.timeout ?? Duration(milliseconds: 200),
                        builder: (BuildContext context, value, Widget child) {
                          return LinearProgressIndicator(
                            value: (1 / widget.items.length > 0
                                    ? 1 / widget.items.length
                                    : 1) *
                                value,
                          );
                        },
                        tween: Tween<double>(begin: 0, end: value.toDouble()),
                      ),
                    ),
                  ),
                  value == widget.items.length || failure
                      ? Container()
                      : InkWell(
                          child: Text('CANCEL'),
                          onTap: () {
                            cancel = true;
                          },
                        ),
                ],
              )
            ],
          );
        });
  }
}
