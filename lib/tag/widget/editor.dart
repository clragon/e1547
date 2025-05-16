import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class TagEditor extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SubTextEditingController(
      builder:
          (context, textController) => SubEffect(
            effect: () {
              controller.setAction(() => submit(textController.text));
              return null;
            },
            child: TagInput(
              labelText: category,
              decoration: const InputDecoration(
                suffix: PromptTextFieldSuffix(icon: Icon(Icons.add)),
              ),
              direction: VerticalDirection.up,
              textInputAction: TextInputAction.done,
              submit: (_) => controller.action!(),
              controller: textController,
              category: TagCategory.byName(category!)?.id,
            ),
          ),
    );
  }
}
