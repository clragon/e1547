import 'package:e1547/post.dart';
import 'package:e1547/tag.dart';
import 'package:flutter/material.dart';

class TagAddCard extends StatefulWidget {
  final Post post;
  final String? category;
  final PostProvider? provider;
  final Future<bool> Function(String value) submit;
  final SheetActionController? controller;

  TagAddCard({
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
        builder: (BuildContext context) {
          return InkWell(
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Icon(Icons.add, size: 16),
            ),
            onTap: () => widget.controller!.show(
              context,
              TagEditor(
                post: widget.post,
                category: widget.category,
                submit: widget.submit,
                controller: widget.controller,
              ),
            ),
          );
        },
      ),
    );
  }
}
