import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class FollowEditor extends StatefulWidget {
  const FollowEditor({super.key});

  @override
  State<FollowEditor> createState() => _FollowEditorState();
}

class _FollowEditorState extends State<FollowEditor> {
  late Client client = context.read<Client>();
  late FollowsService service = context.read<FollowsService>();
  late Future<List<String>> follows = service
      .all(host: client.host)
      .then((value) => value.map((e) => e.tags).toList());

  @override
  Widget build(BuildContext context) {
    Widget title = const Text('Edit follows');
    return FutureLoadingPage<List<String>>(
      title: title,
      future: follows,
      builder: (context, value) => TextEditor(
        title: title,
        content: value.join('\n'),
        onSubmit: (context, value) async {
          List<String> tags = value.split('\n').trim();
          await service.edit(client.host, tags);
          if (context.mounted) {
            Navigator.of(context).maybePop();
          }
          return null;
        },
      ),
    );
  }
}
