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
    return Consumer<FollowsService>(
      builder: (context, follows, child) {
        int unseen = follows.items.fold<int>(
          0,
          (previousValue, element) =>
              previousValue + (follows.status(element)?.unseen ?? 0),
        );
        return ListTile(
          enabled: unseen != 0,
          leading: Icon(unseen != 0 ? Icons.mark_email_read : Icons.drafts),
          title: const Text('unseen posts'),
          subtitle: unseen != 0
              ? TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: unseen),
                  duration: defaultAnimationDuration,
                  builder: (context, value, child) {
                    return Text('mark $value posts as seen');
                  },
                )
              : const Text('no unseen posts'),
          onTap: () {
            Scaffold.of(context).closeEndDrawer();
            follows.markAllAsRead();
          },
        );
      },
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
            builder: (context) => TextEditor(
              title: const Text('Following'),
              content: context.read<FollowsService>().items.tags.join('\n'),
              onSubmit: (context, value) async {
                List<String> tags = value.split('\n').trim();
                tags.removeWhere((tag) => tag.isEmpty);
                context.read<FollowsService>().edit(tags);
                Navigator.pop(context);
                return null;
              },
            ),
          ),
        );
      },
    );
  }
}
