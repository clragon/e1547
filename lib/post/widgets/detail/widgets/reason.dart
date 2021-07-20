import 'package:e1547/post.dart';
import 'package:flutter/material.dart';

class EditReasonEditor extends StatefulWidget {
  final Future<bool> Function(String value) submit;
  final ActionController controller;

  const EditReasonEditor({@required this.controller, @required this.submit});

  @override
  _EditReasonEditorState createState() => _EditReasonEditorState();
}

class _EditReasonEditorState extends State<EditReasonEditor> {
  TextEditingController controller = TextEditingController();

  Future<bool> submit() async => widget.submit(controller.text);

  @override
  void initState() {
    super.initState();
    widget.controller.setAction(submit);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      maxLines: 1,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: 'Edit reason',
        border: UnderlineInputBorder(),
      ),
      onSubmitted: (_) => submit(),
    );
  }
}
