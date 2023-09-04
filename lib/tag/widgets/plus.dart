import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class TagAddCard extends StatefulWidget {
  const TagAddCard({
    super.key,
    required this.submit,
    this.category,
  });

  final String? category;
  final FutureOr<bool> Function(String value)? submit;

  @override
  State<TagAddCard> createState() => _TagAddCardState();
}

class _TagAddCardState extends State<TagAddCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: IconButton(
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(2),
        icon: const Icon(Icons.add, size: 16),
        onPressed: widget.submit != null
            ? () => SheetActions.of(context).show(
                  context,
                  TagEditor(
                    category: widget.category,
                    submit: widget.submit!,
                    controller: SheetActions.of(context),
                  ),
                )
            : null,
      ),
    );
  }
}
