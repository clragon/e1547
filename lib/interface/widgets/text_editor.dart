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

class _TextEditorState extends State<TextEditor>
    with TickerProviderStateMixin, ListenerCallbackMixin {
  bool showBar = true;
  bool isLoading = false;
  late TextEditingController textController =
      TextEditingController(text: widget.content);
  late TabController tabController;

  void onTabChange() {
    if (tabController.index == 0) {
      setState(() {
        showBar = true;
      });
    } else {
      FocusScope.of(context).unfocus();
      setState(() {
        showBar = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      vsync: this,
      length: 2,
    );
    tabController.addListener(onTabChange);
  }

  @override
  void dispose() {
    tabController.removeListener(onTabChange);
    tabController.dispose();
    super.dispose();
  }

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

    return Scaffold(
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
                    controller: tabController,
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
            controller: tabController,
            children: tabs.values.toList(),
          ),
        ),
      ),
    );
  }
}
