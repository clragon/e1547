import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

typedef TextEditorSubmit = FutureOr<String?> Function(String value);
typedef TextEditorBuilder = Widget Function(
    BuildContext context, TextEditingController controller);

class TextEditor extends StatelessWidget {
  const TextEditor({
    super.key,
    this.content,
    required this.onSubmitted,
    this.onClosed,
    this.title,
    this.actions,
    this.preview,
    this.toolbar,
  });

  final String? content;
  final TextEditorSubmit onSubmitted;
  final VoidCallback? onClosed;

  final Widget? title;
  final List<Widget>? actions;
  final TextEditorBuilder? preview;
  final TextEditorBuilder? toolbar;

  static const String _contentKey = 'content';

  @override
  Widget build(BuildContext context) {
    return MultiTextEditor(
      content: [
        TextEditorContent(
          key: _contentKey,
          value: content,
        ),
      ],
      onSubmitted: (values) => onSubmitted.call(values.first.value!),
      onClosed: onClosed,
      title: title,
      actions: actions,
      preview: preview != null
          ? (context, controllers) =>
              preview!.call(context, controllers[_contentKey]!)
          : null,
      toolbar: toolbar != null
          ? (context, controllers) =>
              toolbar!.call(context, controllers[_contentKey]!)
          : null,
    );
  }
}

class TextEditorContent {
  const TextEditorContent({
    required this.key,
    this.title,
    this.value,
  });

  final String key;
  final String? title;
  final String? value;
}

typedef MultiTextEditorSubmit = FutureOr<String?> Function(
    List<TextEditorContent> values);
typedef MultiTextEditorBuilder = Widget Function(
    BuildContext context, Map<String, TextEditingController> controllers);

class MultiTextEditor extends StatefulWidget {
  const MultiTextEditor({
    super.key,
    required this.content,
    required this.onSubmitted,
    this.onClosed,
    this.title,
    this.actions,
    this.preview,
    this.toolbar,
  });

  final List<TextEditorContent> content;
  final MultiTextEditorSubmit onSubmitted;
  final VoidCallback? onClosed;

  final Widget? title;
  final List<Widget>? actions;
  final MultiTextEditorBuilder? preview;
  final MultiTextEditorBuilder? toolbar;

  @override
  State<MultiTextEditor> createState() => _MultiTextEditorState();
}

class _MultiTextEditorState extends State<MultiTextEditor> {
  late Map<TextEditorContent, TextEditingController> textControllers = {
    for (final content in widget.content)
      content: TextEditingController(text: content.value),
  };
  Map<String, TextEditingController> get textControllerMap {
    return {
      for (final content in textControllers.keys)
        content.key: textControllers[content]!,
    };
  }

  late LoadingDialogActionController actionController =
      LoadingDialogActionController();

  Future<void> submit() async {
    String? error = await widget.onSubmitted(
      [
        for (final content in textControllers.keys)
          TextEditorContent(
            key: content.key,
            title: content.title,
            value: textControllers[content]!.text.trim(),
          ),
      ],
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
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: defaultActionListPadding.add(const EdgeInsets.all(8)),
                sliver: SliverFillRemaining(
                  hasScrollBody: false,
                  child: child,
                ),
              ),
            ],
          );
        }

        Widget editor() {
          return scrollView(
            Column(
              children: [
                for (final content in textControllers.keys)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (content.title != null)
                        Text(
                          content.title!,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      TextField(
                        controller: textControllers[content],
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'type here...',
                        ),
                        maxLines: null,
                        enabled: !actionController.isLoading,
                      ),
                    ],
                  ),
              ],
            ),
          );
        }

        Widget fab() {
          return Builder(
            builder: (context) => FloatingActionButton(
              backgroundColor: Theme.of(context).cardColor,
              onPressed: actionController.isLoading
                  ? null
                  : () async {
                      await actionController.showAndAction(context, submit);
                      if (!actionController.isError) {
                        widget.onClosed?.call();
                      }
                    },
              child:
                  Icon(Icons.check, color: Theme.of(context).iconTheme.color),
            ),
          );
        }

        Map<Widget, Widget>? tabs = {
          const Tab(text: 'Write'): editor(),
          if (widget.preview case final preview?)
            const Tab(text: 'Preview'): scrollView(
              preview(
                context,
                textControllerMap,
              ),
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
                      ? widget.toolbar?.call(context, textControllerMap)
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
                          actions: widget.actions,
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
