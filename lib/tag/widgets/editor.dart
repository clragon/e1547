import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class TagEditor extends StatefulWidget {
  const TagEditor({
    super.key,
    required this.category,
    required this.submit,
    required this.controller,
  });

  final String? category;
  final FutureOr<bool> Function(String text) submit;
  final ActionController controller;

  @override
  State<TagEditor> createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.setAction(() => widget.submit(controller.text));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TagInput(
      labelText: widget.category,
      direction: VerticalDirection.up,
      textInputAction: TextInputAction.done,
      submit: (_) => widget.controller.action!(),
      controller: controller,
      category: TagCategory.byName(widget.category!).id,
    );
  }
}
