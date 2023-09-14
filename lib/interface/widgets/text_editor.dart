import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

typedef TextEditorSubmit = FutureOr<String?> Function(
    BuildContext context, String value);
typedef TextEditorBuilder = Widget Function(
    BuildContext context, TextEditingController controller);

class TextEditor extends StatefulWidget {
  const TextEditor({
    super.key,
    required this.onSubmit,
    this.title,
    this.content,
    this.actions,
    this.preview,
    this.toolbar,
  });

  final Widget? title;
  final String? content;

  final TextEditorSubmit onSubmit;

  final List<Widget>? Function(
    BuildContext context,
    TextEditingController controller,
  )? actions;
  final TextEditorBuilder? preview;
  final TextEditorBuilder? toolbar;

  @override
  State<StatefulWidget> createState() {
    return _TextEditorState();
  }
}

class _TextEditorState extends State<TextEditor> {
  late LoadingDialogActionController actionController =
      LoadingDialogActionController();
  late TextEditingController textController =
      TextEditingController(text: widget.content);

  Future<void> submit() async {
    String? error = await widget.onSubmit(
      context,
      textController.text.trim(),
    );
    if (error != null) {
      throw ActionControllerException(message: error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: actionController,
      builder: (context, child) {
        Widget scrollView(Widget child) {
          return SingleChildScrollView(
            padding: defaultActionListPadding.add(const EdgeInsets.all(8)),
            child: Row(
              children: [Expanded(child: child)],
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
              enabled: !actionController.isLoading,
            ),
          );
        }

        Widget fab() {
          return Builder(
            builder: (context) => FloatingActionButton(
              backgroundColor: Theme.of(context).cardColor,
              onPressed: actionController.isLoading
                  ? null
                  : () => actionController.showAndAction(context, submit),
              child:
                  Icon(Icons.check, color: Theme.of(context).iconTheme.color),
            ),
          );
        }

        Map<Widget, Widget>? tabs = {
          const Tab(text: 'Write'): editor(),
          if (widget.preview case final preview?)
            const Tab(text: 'Preview'): scrollView(
              preview(context, textController),
            ),
        };

        return DefaultTabController(
          length: tabs.length,
          child: Builder(
            builder: (context) {
              TabController tabController = DefaultTabController.of(context);
              return ListenableBuilder(
                listenable: tabController,
                builder: (context, child) => Scaffold(
                  floatingActionButton: fab(),
                  bottomSheet: tabController.index == 0
                      ? widget.toolbar?.call(context, textController)
                      : null,
                  body: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      SliverOverlapAbsorber(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context,
                        ),
                        sliver: DefaultSliverAppBar(
                          pinned: true,
                          leading: ModalRoute.of(context)!.canPop
                              ? const CloseButton()
                              : null,
                          title: widget.title,
                          actions:
                              widget.actions?.call(context, textController),
                          bottom: tabs.length > 1
                              ? TabBar(
                                  tabs: tabs.keys.toList(),
                                  labelColor: Theme.of(context).iconTheme.color,
                                  indicatorColor:
                                      Theme.of(context).iconTheme.color,
                                )
                              : null,
                        ),
                      ),
                    ],
                    body: TabBarView(
                      children: tabs.values.toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
