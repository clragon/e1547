import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class TagAddCard extends StatefulWidget {
  final String? category;
  final Future<bool> Function(String value) submit;
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
        builder: (context) => InkWell(
          child: Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.add, size: 16),
          ),
          onTap: () => widget.controller.show(
            context,
            TagEditor(
              category: widget.category,
              submit: widget.submit,
              controller: widget.controller,
            ),
          ),
        ),
      ),
    );
  }
}
