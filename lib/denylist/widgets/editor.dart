import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/material.dart';

class DenylistEditor extends StatelessWidget {
  final List<String> denylist;

  const DenylistEditor({required this.denylist});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller =
        TextEditingController(text: denylist.join('\n'));
    return LoadingDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Blacklist'),
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => wikiSheet(context: context, tag: 'e621:blacklist'),
          )
        ],
      ),
      builder: (context, submit) => TextField(
        scrollPhysics: BouncingScrollPhysics(),
        controller: controller,
        keyboardType: TextInputType.multiline,
        maxLines: null,
      ),
      submit: () async {
        List<String> tags = controller.text.split('\n');
        tags = tags.trim();
        tags.removeWhere((tag) => tag.isEmpty);
        if (!await updateBlacklist(context: context, denylist: tags)) {
          throw ControllerException(message: 'Failed to update blacklist!');
        }
      },
    );
  }
}
