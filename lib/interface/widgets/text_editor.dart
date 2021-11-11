import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class TextEditor extends StatefulWidget {
  final String title;
  final String? content;
  final bool richEditor;
  final Future<bool> Function(BuildContext context, String text)? validator;

  const TextEditor({
    required this.title,
    this.content,
    required this.validator,
    this.richEditor = true,
  });

  @override
  State<StatefulWidget> createState() {
    return _TextEditorState();
  }
}

class _TextEditorState extends State<TextEditor>
    with TickerProviderStateMixin, LinkingMixin {
  bool showBar = true;
  bool isLoading = false;
  TabController? tabController;
  TextEditingController textController = TextEditingController();

  @override
  Map<ChangeNotifier, VoidCallback> get links => {
        textController: () => setState(() {}),
      };

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      vsync: this,
      length: 2,
    );
    textController.text = widget.content ?? '';
    tabController!.addListener(() {
      if (tabController!.index == 0) {
        setState(() {
          showBar = true;
        });
      } else {
        FocusScope.of(context).unfocus();
        setState(() {
          showBar = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget frame(Widget child) {
      return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: child,
                  )
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget editor() {
      return frame(Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: TextField(
          controller: textController,
          keyboardType: TextInputType.multiline,
          autofocus: true,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'type here...',
          ),
          maxLines: null,
          enabled: !isLoading,
        ),
      ));
    }

    Widget preview() {
      Widget child;
      if (textController.text.trim().isNotEmpty) {
        child = DTextField(source: textController.text);
      } else {
        child = Text(
          'your text here',
          style: TextStyle(
            color:
                Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.35),
            fontStyle: FontStyle.italic,
          ),
        );
      }

      return frame(
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: child,
          ),
        ),
      );
    }

    Widget fab() {
      return Builder(
        builder: (context) {
          return FloatingActionButton(
            heroTag: 'float',
            backgroundColor: Theme.of(context).cardColor,
            child: Icon(Icons.check, color: Theme.of(context).iconTheme.color),
            onPressed: isLoading
                ? null
                : () async {
                    String text = textController.text.trim();
                    setState(() {
                      isLoading = true;
                    });
                    if ((await widget.validator?.call(context, text)) ?? true) {
                      Navigator.of(context).pop();
                    }
                    setState(() {
                      isLoading = false;
                    });
                  },
          );
        },
      );
    }

    Widget loadingBar() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedCircularProgressIndicator(size: 20),
                ],
              ),
            )
          ],
        ),
      );
    }

    Map<Widget, Widget> tabs = {
      Tab(text: 'WRITE'): editor(),
      Tab(text: 'PREVIEW'): preview(),
    };

    return Scaffold(
      floatingActionButton: fab(),
      bottomSheet: isLoading
          ? loadingBar()
          : (widget.richEditor && showBar)
              ? EditorBar(controller: textController)
              : null,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            leading: CloseButton(),
            title: Text(widget.title),
            bottom: widget.richEditor
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
          padding: EdgeInsets.only(bottom: 42),
          child: widget.richEditor
              ? TabBarView(
                  controller: tabController,
                  children: tabs.values.toList(),
                )
              : editor(),
        ),
      ),
    );
  }
}

class EditorBar extends StatefulWidget {
  final TextEditingController controller;

  const EditorBar({required this.controller});

  @override
  _EditorBarState createState() => _EditorBarState();
}

class _EditorBarState extends State<EditorBar> {
  bool showBlocks = false;

  @override
  Widget build(BuildContext context) {
    void enclose(String blockTag, {String? endTag}) {
      String before = widget.controller.text
          .substring(0, widget.controller.selection.baseOffset);
      String block = widget.controller.text.substring(
          widget.controller.selection.baseOffset,
          widget.controller.selection.extentOffset);
      String after = widget.controller.text
          .substring(widget.controller.selection.extentOffset);
      int pos = before.length + block.length + '[$blockTag]'.length;
      block = '[$blockTag]$block[/${endTag ?? blockTag}]';
      widget.controller.text = '$before$block$after';
      widget.controller.selection = TextSelection(
        baseOffset: pos,
        extentOffset: pos,
      );
    }

    Widget blockButtons() {
      return Row(
        children: [
          IconButton(
            icon: Icon(Icons.subject),
            onPressed: () => enclose('section,expanded=', endTag: 'section'),
            tooltip: 'Section',
          ),
          IconButton(
            icon: Icon(Icons.format_quote),
            onPressed: () => enclose('quote'),
            tooltip: 'Quote',
          ),
          IconButton(
            icon: Icon(Icons.code),
            onPressed: () => enclose('code'),
            tooltip: 'Code',
          ),
          IconButton(
            icon: Icon(Icons.warning),
            onPressed: () => enclose('spoiler'),
            tooltip: 'Spoiler',
          ),
        ],
      );
    }

    Widget textButtons() {
      return Row(
        children: [
          IconButton(
            icon: Icon(Icons.format_bold),
            onPressed: () => enclose('b'),
            tooltip: 'Bold',
          ),
          IconButton(
            icon: Icon(Icons.format_italic),
            onPressed: () => enclose('i'),
            tooltip: 'Italic',
          ),
          IconButton(
            icon: Icon(Icons.format_underlined),
            onPressed: () => enclose('u'),
            tooltip: 'Underlined',
          ),
          IconButton(
            icon: Icon(Icons.format_strikethrough),
            onPressed: () => enclose('s'),
            tooltip: 'Strikethrough',
          ),
        ],
      );
    }

    Widget switcher() {
      return IntrinsicHeight(
        child: Row(
          children: [
            VerticalDivider(),
            ExpandIcon(
              isExpanded: showBlocks,
              onPressed: (value) => setState(() {
                showBlocks = !value;
              }),
            )
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int rowSize = (constraints.maxWidth / 40).round();
        bool showAll = rowSize > 10;
        return Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  CrossFade(
                      showChild: showAll || showBlocks, child: blockButtons()),
                  CrossFade(
                      showChild: showAll || !showBlocks, child: textButtons()),
                  CrossFade(
                    showChild: !showAll,
                    child: switcher(),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
