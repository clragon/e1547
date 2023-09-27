import 'package:collection/collection.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class FollowEditor extends StatefulWidget {
  const FollowEditor({super.key});

  @override
  State<FollowEditor> createState() => _FollowEditorState();
}

class _FollowEditorState extends State<FollowEditor> {
  final String notify = FollowType.notify.name;
  final String subscribe = FollowType.update.name;
  final String bookmark = FollowType.bookmark.name;

  late FollowsService service = context.read<FollowsService>();
  late Future<Map<String, String>> follows = Future(
    () async => {
      notify: await service.all(types: [FollowType.notify]).then(followString),
      subscribe:
          await service.all(types: [FollowType.update]).then(followString),
      bookmark:
          await service.all(types: [FollowType.bookmark]).then(followString),
    },
  );

  String followString(List<Follow> follows) {
    return follows.map((e) => e.tags).join('\n');
  }

  @override
  Widget build(BuildContext context) {
    Widget title = const Text('Edit follows');
    return FutureLoadingPage<Map<String, String>>(
      title: title,
      future: follows,
      builder: (context, value) => MultiTextEditor(
        title: title,
        content: [
          TextEditorContent(
            key: notify,
            title: 'Notify',
            value: value[notify],
          ),
          TextEditorContent(
            key: subscribe,
            title: 'Subscribe',
            value: value[subscribe],
          ),
          TextEditorContent(
            key: bookmark,
            title: 'Bookmark',
            value: value[bookmark],
          ),
        ],
        onSubmit: (value) async {
          await service.edit(
            value
                .firstWhere((e) => e.key == notify)
                .value!
                .split('\n')
                .whereNot((e) => e.isEmpty)
                .toList(),
            value
                .firstWhere((e) => e.key == subscribe)
                .value!
                .split('\n')
                .whereNot((e) => e.isEmpty)
                .toList(),
            value
                .firstWhere((e) => e.key == bookmark)
                .value!
                .split('\n')
                .whereNot((e) => e.isEmpty)
                .toList(),
          );
          if (context.mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).maybePop();
            });
          }
          return null;
        },
      ),
    );
  }
}
