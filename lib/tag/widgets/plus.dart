import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class TagAddCard extends StatefulWidget {
  final Post post;
  final String? category;
  final PostController? provider;
  final Future<bool> Function(String value) submit;
  final SheetActionController controller;

  const TagAddCard({
    required this.post,
    required this.provider,
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
        builder: (BuildContext context) => InkWell(
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Icon(Icons.add, size: 16),
          ),
          onTap: () => widget.controller.show(
            context,
            TagEditor(
              post: widget.post,
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
