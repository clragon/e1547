import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class TagAddCard extends StatefulWidget {
  final String? category;
  final FutureOr<bool> Function(String value)? submit;
  final SheetActionController controller;

  const TagAddCard({
    required this.submit,
    required this.controller,
    this.category,
  });

  @override
  _TagAddCardState createState() => _TagAddCardState();
}

class _TagAddCardState extends State<TagAddCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Builder(
        builder: (context) => IconButton(
          constraints: BoxConstraints(),
          padding: EdgeInsets.all(2),
          icon: Icon(Icons.add, size: 16),
          onPressed:  widget.submit != null
              ? () => widget.controller.show(
            context,
            TagEditor(
              category: widget.category,
              submit: widget.submit!,
              controller: widget.controller,
            ),
          )
              : null,
        )
      ),
    );
  }
}
