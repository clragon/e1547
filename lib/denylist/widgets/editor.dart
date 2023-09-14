import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class DenyListEditor extends StatelessWidget {
  const DenyListEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return TextEditor(
      title: const Text('Blacklist'),
      actions: (context, controller) => [
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () =>
              showTagSearchPrompt(context: context, tag: 'e621:blacklist'),
        )
      ],
      content: context.read<DenylistService>().items.join('\n'),
      onSubmit: (context, value) async {
        List<String> tags = value.split('\n');
        tags = tags.trim();
        tags.removeWhere((tag) => tag.isEmpty);
        try {
          await context.read<DenylistService>().set(tags);
        } on DenylistUpdateException {
          return 'Failed to update blacklist!';
        }
        if (context.mounted) {
          Navigator.of(context).maybePop();
        }
        return null;
      },
    );
  }
}
