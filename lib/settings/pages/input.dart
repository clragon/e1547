import 'package:e1547/interface.dart';
import 'package:e1547/tag.dart';
import 'package:flutter/material.dart';

class ListTagEditor extends StatefulWidget {
  final TextEditingController controller;
  final Function(String value) onSubmit;
  final String prompt;

  const ListTagEditor(
      {@required this.onSubmit, this.controller, @required this.prompt});

  @override
  _ListTagEditorState createState() => _ListTagEditorState();
}

class _ListTagEditorState extends State<ListTagEditor> {
  TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    controller ??= TextEditingController();
    setFocusToEnd(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TagInput(
          controller: controller,
          labelText: widget.prompt,
          onSubmit: widget.onSubmit,
        ),
      ]),
    );
  }
}
