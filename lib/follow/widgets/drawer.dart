import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
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
            follows.markAllAsRead();
            Navigator.of(context).maybePop();
          },
        );
      },
    );
  }
}

class FollowSettingsTile extends StatelessWidget {
  const FollowSettingsTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.turned_in),
      title: const Text('Settings'),
      onTap: () async {
        Scaffold.of(context).closeEndDrawer();
        Navigator.of(context).pushNamed('/following');
      },
    );
  }
}
