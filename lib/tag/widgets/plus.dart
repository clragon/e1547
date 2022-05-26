import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class TagAddCard extends StatefulWidget {
  final String? category;
  final FutureOr<bool> Function(String value)? submit;

  const TagAddCard({
    required this.submit,
    this.category,
  });

  @override
  State<TagAddCard> createState() => _TagAddCardState();
}

class _TagAddCardState extends State<TagAddCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Builder(
        builder: (context) => IconButton(
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(2),
          icon: const Icon(Icons.add, size: 16),
          onPressed: widget.submit != null
              ? () => SheetActions.of(context)!.show(
                    context,
                    TagEditor(
                      category: widget.category,
                      submit: widget.submit!,
                      controller: SheetActions.of(context)!,
                    ),
                  )
              : null,
        ),
      ),
    );
  }
}
