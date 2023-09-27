import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class DenyListEditor extends StatelessWidget {
  const DenyListEditor({super.key});

  @override
  Widget build(BuildContext context) {
    Client client = context.read<Client>();
    return TextEditor(
      title: const Text('Blacklist'),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () =>
              showTagSearchPrompt(context: context, tag: 'e621:blacklist'),
        )
      ],
      content: client.traits.value.denylist.join('\n'),
      onSubmit: (value) async {
        List<String> tags = value.split('\n');
        tags = tags.trim();
        tags.removeWhere((tag) => tag.isEmpty);
        client.traits.value = client.traits.value.copyWith(
          denylist: tags,
        );
        if (context.mounted) {
          Navigator.of(context).maybePop();
        }
        return null;
      },
    );
  }
}
