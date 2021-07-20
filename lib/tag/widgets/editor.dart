import 'package:e1547/post.dart';
import 'package:e1547/tag.dart';
import 'package:flutter/material.dart';

class TagEditor extends StatefulWidget {
  final Post post;
  final String category;
  final Future<bool> Function(String text) submit;
  final ActionController controller;

  TagEditor({
    @required this.post,
    @required this.category,
    this.submit,
    this.controller,
  });

  @override
  _TagEditorState createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.setAction(() => widget.submit(controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return TagInput(
      labelText: widget.category,
      onSubmit: (_) => widget.controller.action(),
      controller: controller,
      category: categories[widget.category],
    );
  }
}
