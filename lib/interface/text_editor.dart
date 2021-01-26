import 'package:e1547/interface/cross_fade.dart';
import 'package:e1547/interface/dtext_field.dart';
import 'package:flutter/material.dart';

class TextEditor extends StatefulWidget {
  final String title;
  final String content;
  final bool richEditor;
  final Future<bool> Function(BuildContext context, String text) validator;

  const TextEditor({
    @required this.title,
    this.content,
    @required this.validator,
    this.richEditor = true,
  });

  @override
  State<StatefulWidget> createState() {
    return _TextEditorState();
  }
}

class _TextEditorState extends State<TextEditor> with TickerProviderStateMixin {
  bool showBar = true;
  bool showBlocks = false;
  bool isLoading = false;
  TabController tabController;
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      vsync: this,
      length: 2,
    );
    textController.text = widget.content ?? '';
    tabController.addListener(() {
      if (tabController.index == 0) {
        setState(() {
          showBar = true;
        });
      } else {
        setState(() {
          FocusScope.of(context).unfocus();
          showBar = false;
        });
      }
    });
    textController.addListener(() {
      setState(() {});
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
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
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
        padding: EdgeInsets.only(left: 8, right: 8),
        child: TextField(
          controller: textController,
          keyboardType: TextInputType.multiline,
          autofocus: true,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'type here...',
          ),
          maxLines: null,
        ),
      ));
    }

    Widget preview() {
      return frame(
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: textController.text.trim().isNotEmpty
                ? DTextField(msg: textController.text.trim())
                : Text('your text here',
                    style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText1
                            .color
                            .withOpacity(0.35),
                        fontStyle: FontStyle.italic)),
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
            onPressed: () async {
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

    Widget hotkeys() {
      void enclose(String blockTag, {String endTag}) {
        String before = textController.text
            .substring(0, textController.selection.baseOffset);
        String block = textController.text.substring(
            textController.selection.baseOffset,
            textController.selection.extentOffset);
        String after = textController.text
            .substring(textController.selection.extentOffset);
        int pos = before.length + block.length + '[$blockTag]'.length;
        block = '[$blockTag]$block[/${endTag ?? blockTag}]';
        textController.text = '$before$block$after';
        textController.selection = TextSelection(
          baseOffset: pos,
          extentOffset: pos,
        );
      }

      return OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          return Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: () {
                      List<Widget> buttons = [];
                      int rowSize =
                          (MediaQuery.of(context).size.width / 40).round();
                      List<Widget> blockButtons = [
                        IconButton(
                          icon: Icon(Icons.subject),
                          onPressed: () =>
                              enclose('section,expanded=', endTag: 'section'),
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
                      ];
                      List<Widget> textbuttons = [
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
                      ];

                      if (rowSize > 10) {
                        buttons.addAll(textbuttons);
                        buttons.addAll(blockButtons);
                      } else {
                        buttons.add(CrossFade(
                          showChild: showBlocks,
                          child: Row(
                            children: blockButtons,
                          ),
                          secondChild: Row(
                            children: textbuttons,
                          ),
                        ));
                        buttons.addAll([
                          VerticalDivider(),
                          IconButton(
                            icon: Icon(showBlocks
                                ? Icons.expand_less
                                : Icons.expand_more),
                            onPressed: () => setState(() {
                              showBlocks = !showBlocks;
                            }),
                          ),
                        ]);
                      }
                      return buttons;
                    }(),
                  ),
                )
              ]));
        },
      );
    }

    return Scaffold(
        floatingActionButton: fab(),
        bottomSheet: () {
          if (isLoading) {
            return Padding(
                padding: EdgeInsets.only(
                    left: 10.0, right: 10.0, bottom: 16, top: 16),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(),
                        )
                      ],
                    ),
                  )
                ]));
          }
          return (widget.richEditor && showBar) ? hotkeys() : null;
        }(),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                floating: true,
                pinned: false,
                snap: false,
                leading: IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(widget.title),
                bottom: widget.richEditor
                    ? TabBar(
                        controller: tabController,
                        tabs: [
                          Tab(text: 'WRITE'),
                          Tab(text: 'PREVIEW'),
                        ],
                      )
                    : null,
              ),
            ];
          },
          body: Padding(
            padding: EdgeInsets.only(bottom: 42),
            child: widget.richEditor
                ? TabBarView(
                    controller: tabController,
                    children: [
                      editor(),
                      preview(),
                    ],
                  )
                : editor(),
          ),
        ));
  }
}
