import 'package:async_builder/async_builder.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

class FollowMarkReadTile extends StatefulWidget {
  const FollowMarkReadTile();

  @override
  State<FollowMarkReadTile> createState() => _FollowMarkReadTileState();
}

class _FollowMarkReadTileState extends State<FollowMarkReadTile> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<FollowsService, Client>(
      builder: (context, service, client, child) =>
          SubValueBuilder<Stream<int>>(
        create: (context) =>
            service.watchUnseen(host: client.host).map((e) => e.length),
        selector: (context) => [service, client.host],
        builder: (context, stream) => AsyncBuilder<int>(
          stream: stream,
          builder: (context, value) => ListTile(
            enabled: value != 0,
            leading: Icon(value != 0 ? Icons.mark_email_read : Icons.drafts),
            title: const Text('unseen posts'),
            subtitle: value != 0
                ? TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: value ?? 0),
                    duration: defaultAnimationDuration,
                    builder: (context, value, child) {
                      return Text('mark $value posts as seen');
                    },
                  )
                : const Text('no unseen posts'),
            onTap: () {
              Scaffold.of(context).closeEndDrawer();
              service.markAllAsRead();
            },
          ),
        ),
      ),
    );
  }
}

class FollowSwitcherTile extends StatefulWidget {
  const FollowSwitcherTile();

  @override
  State<FollowSwitcherTile> createState() => _FollowSwitcherTileState();
}

class _FollowSwitcherTileState extends State<FollowSwitcherTile> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: context.watch<Settings>().splitFollows,
      builder: (context, value, child) => SwitchListTile(
        secondary: Icon(value ? Icons.view_comfy : Icons.view_list),
        title: const Text('Split searches'),
        subtitle: value ? const Text('folders') : const Text('timeline'),
        value: value,
        onChanged: (value) async {
          Scaffold.of(context).closeEndDrawer();
          context.read<Settings>().splitFollows.value = value;
        },
      ),
    );
  }
}

class FollowEditingTile extends StatelessWidget {
  const FollowEditingTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Edit'),
      leading: const Icon(Icons.edit),
      onTap: () {
        Scaffold.of(context).closeEndDrawer();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const FollowEditor(),
          ),
        );
      },
    );
  }
}

class FollowEditor extends StatefulWidget {
  const FollowEditor({super.key});

  @override
  State<FollowEditor> createState() => _FollowEditorState();
}

class _FollowEditorState extends State<FollowEditor> {
  late Client client = context.read<Client>();
  late FollowsService service = context.read<FollowsService>();
  late Future<List<String>> follows = service
      .getAll(host: client.host)
      .then((value) => value.map((e) => e.tags).toList());

  @override
  Widget build(BuildContext context) {
    Widget title = const Text('Following');
    return FutureLoadingPage<List<String>>(
      title: title,
      future: follows,
      builder: (context, value) => TextEditor(
        title: title,
        content: value.join('\n'),
        onSubmit: (context, value) async {
          List<String> tags = value.split('\n').trim();
          tags.removeWhere((tag) => tag.isEmpty);
          service.edit(client.host, tags);
          Navigator.pop(context);
          return null;
        },
      ),
    );
  }
}
