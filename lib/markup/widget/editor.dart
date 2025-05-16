import 'package:e1547/interface/interface.dart';
import 'package:e1547/markup/markup.dart';
import 'package:flutter/material.dart';
import 'package:overflow_view/overflow_view.dart';

class DTextEditor extends StatelessWidget {
  const DTextEditor({
    super.key,
    this.title,
    required this.onSubmitted,
    this.onClosed,
    this.content,
  });

  final Widget? title;
  final String? content;
  final TextEditorSubmit onSubmitted;
  final VoidCallback? onClosed;

  @override
  Widget build(BuildContext context) {
    return TextEditor(
      onSubmitted: onSubmitted,
      onClosed: onClosed,
      title: title,
      content: content,
      toolbar: (context, controller) => DTextEditorBar(controller: controller),
      preview:
          (context, controller) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  if (controller.text.trim().isNotEmpty) {
                    return DText(controller.text);
                  } else {
                    return Text(
                      'your text here',
                      style: TextStyle(
                        color: dimTextColor(context),
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  }
                },
              ),
            ),
          ),
    );
  }
}

class DTextEditorBar extends StatefulWidget {
  const DTextEditorBar({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<DTextEditorBar> createState() => _DTextEditorBarState();
}

class _DTextEditorBarState extends State<DTextEditorBar> {
  bool showBlocks = false;

  @override
  Widget build(BuildContext context) {
    void enclose(String blockTag, {String? endTag}) {
      int base = widget.controller.selection.baseOffset;
      int extent = widget.controller.selection.extentOffset;

      int start;
      int end;
      if (base <= extent) {
        start = base;
        end = extent;
      } else {
        start = extent;
        end = base;
      }

      String before = widget.controller.text.substring(0, start);
      String block = widget.controller.text.substring(start, end);
      String after = widget.controller.text.substring(end);

      String blockStart = '[$blockTag]$block';
      String blockEnd = '[/${endTag ?? blockTag}]';
      int cursorOffset = before.length + blockStart.length;

      block = blockStart + blockEnd;
      widget.controller.text = '$before$block$after';

      widget.controller.selection = TextSelection(
        baseOffset: cursorOffset,
        extentOffset: cursorOffset,
      );
    }

    Widget blockButtons() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.subject),
            onPressed: () => enclose('section,expanded=', endTag: 'section'),
            tooltip: 'Section',
          ),
          IconButton(
            icon: const Icon(Icons.format_quote),
            onPressed: () => enclose('quote'),
            tooltip: 'Quote',
          ),
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: () => enclose('code'),
            tooltip: 'Code',
          ),
          IconButton(
            icon: const Icon(Icons.warning),
            onPressed: () => enclose('spoiler'),
            tooltip: 'Spoiler',
          ),
        ],
      );
    }

    Widget textButtons() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.format_bold),
            onPressed: () => enclose('b'),
            tooltip: 'Bold',
          ),
          IconButton(
            icon: const Icon(Icons.format_italic),
            onPressed: () => enclose('i'),
            tooltip: 'Italic',
          ),
          IconButton(
            icon: const Icon(Icons.format_underlined),
            onPressed: () => enclose('u'),
            tooltip: 'Underlined',
          ),
          IconButton(
            icon: const Icon(Icons.format_strikethrough),
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
            const VerticalDivider(),
            ExpandIcon(
              isExpanded: showBlocks,
              onPressed:
                  (value) => setState(() {
                    showBlocks = !value;
                  }),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: OverflowView(
        children: [
          CrossFade(
            showChild: showBlocks,
            secondChild: textButtons(),
            child: blockButtons(),
          ),
          CrossFade(
            showChild: showBlocks,
            secondChild: blockButtons(),
            child: textButtons(),
          ),
          const SizedBox(width: 48),
        ],
        builder:
            (context, remaining) =>
                remaining == 3 ? const SizedBox() : switcher(),
      ),
    );
  }
}
