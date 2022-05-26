import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class DenyListEditor extends StatefulWidget {
  const DenyListEditor();

  @override
  State<DenyListEditor> createState() => _DenyListEditorState();
}

class _DenyListEditorState extends State<DenyListEditor> {
  TextEditingController controller =
      TextEditingController(text: denylistController.items.join('\n'));

  @override
  Widget build(BuildContext context) {
    return LoadingDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Blacklist'),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () =>
                tagSearchSheet(context: context, tag: 'e621:blacklist'),
          )
        ],
      ),
      builder: (context, submit) => TextField(
        controller: controller,
        keyboardType: TextInputType.multiline,
        maxLines: null,
      ),
      submit: () async {
        List<String> tags = controller.text.split('\n');
        tags = tags.trim();
        tags.removeWhere((tag) => tag.isEmpty);
        await denylistController.edit(tags);
        if (!await validateCall(() => denylistController.edit(tags))) {
          throw const ActionControllerException(
              message: 'Failed to update blacklist!');
        }
      },
    );
  }
}
