import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

// TODO: replace with validator, remove pop
typedef TextEditorSubmit = FutureOr<bool> Function(
    BuildContext context, String text);
typedef TextEditorBuilder = Widget Function(
    BuildContext context, TextEditingController controller);

class TextEditor extends StatefulWidget {
  final String title;
  final String? content;

  final TextEditorSubmit onSubmit;

  final TextEditorBuilder? previewBuilder;
  final TextEditorBuilder? bottomSheetBuilder;

  factory TextEditor({
    required TextEditorSubmit onSubmit,
    required String title,
    String? content,
  }) {
    return TextEditor.builder(
      onSubmit: onSubmit,
      title: title,
      content: content,
    );
  }

  const TextEditor.builder({
    required this.onSubmit,
    required this.title,
    this.content,
    this.previewBuilder,
    this.bottomSheetBuilder,
  });

  @override
  State<StatefulWidget> createState() {
    return _TextEditorState();
  }
}

class _TextEditorState extends State<TextEditor> {
  late bool showBar = widget.bottomSheetBuilder != null;
  bool isLoading = false;
  late TextEditingController textController =
      TextEditingController(text: widget.content);

  @override
  Widget build(BuildContext context) {
    Widget scrollView(Widget child) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: child,
              )
            ],
          ),
        ),
      );
    }

    Widget editor() {
      return scrollView(
        TextField(
          controller: textController,
          keyboardType: TextInputType.multiline,
          autofocus: true,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'type here...',
          ),
          maxLines: null,
          enabled: !isLoading,
        ),
      );
    }

    Widget fab() {
      return Builder(
        builder: (context) => FloatingActionButton(
          heroTag: 'float',
          backgroundColor: Theme.of(context).cardColor,
          onPressed: isLoading
              ? null
              : () async {
                  String text = textController.text.trim();
                  setState(() {
                    isLoading = true;
                  });
                  if (await widget.onSubmit(context, text)) {
                    Navigator.of(context).maybePop();
                  }
                  setState(() {
                    isLoading = false;
                  });
                },
          child: Icon(Icons.check, color: Theme.of(context).iconTheme.color),
        ),
      );
    }

    Widget loadingBar() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedCircularProgressIndicator(size: 24),
          ],
        ),
      );
    }

    Map<Widget, Widget>? tabs = {
      const Tab(text: 'Write'): editor(),
    };

    if (widget.previewBuilder != null) {
      tabs.addAll({
        const Tab(text: 'Preview'):
            scrollView(widget.previewBuilder!(context, textController)),
      });
    }

    return DefaultTabController(
      length: tabs.length,
      child: Builder(
        builder: (context) {
          TabController controller = DefaultTabController.of(context)!;
          return ListenableListener(
            listener: () {
              if (controller.length > 1 && controller.index == 0) {
                if (!showBar) {
                  setState(() {
                    showBar = true;
                  });
                }
              } else {
                if (showBar) {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    showBar = false;
                  });
                }
              }
            },
            listenable: DefaultTabController.of(context)!,
            child: Scaffold(
              floatingActionButton: fab(),
              bottomSheet: isLoading
                  ? loadingBar()
                  : showBar
                      ? widget.bottomSheetBuilder?.call(context, textController)
                      : null,
              body: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  DefaultSliverAppBar(
                    floating: true,
                    leading: const CloseButton(),
                    title: Text(widget.title),
                    bottom: tabs.length > 1
                        ? TabBar(
                            tabs: tabs.keys.toList(),
                            labelColor: Theme.of(context).iconTheme.color,
                            indicatorColor: Theme.of(context).iconTheme.color,
                          )
                        : null,
                  ),
                ],
                body: Padding(
                  padding: defaultActionListPadding,
                  child: TabBarView(
                    children: tabs.values.toList(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
