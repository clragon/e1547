import 'package:e1547/domain/domain.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class DenyListEditor extends StatelessWidget {
  const DenyListEditor({super.key});

  @override
  Widget build(BuildContext context) {
    final domain = context.read<Domain>();
    return TextEditor(
      title: const Text('Blacklist'),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () =>
              showTagSearchPrompt(context: context, tag: 'e621:blacklist'),
        ),
      ],
      content: domain.traits.value.denylist.join('\n'),
      onSubmitted: (value) async {
        List<String> tags = value.split('\n');
        tags = tags.trim();
        tags.removeWhere((tag) => tag.isEmpty);
        try {
          await domain.accounts.push(
            traits: domain.traits.value.copyWith(denylist: tags),
          );
        } on ClientException {
          return 'Failed to update blacklist!';
        }
        return null;
      },
      onClosed: Navigator.of(context).maybePop,
    );
  }
}
