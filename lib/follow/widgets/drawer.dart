import 'package:e1547/follow.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

class FollowMarkReadTile extends StatefulWidget {
  const FollowMarkReadTile();

  @override
  _FollowMarkReadTileState createState() => _FollowMarkReadTileState();
}

class _FollowMarkReadTileState extends State<FollowMarkReadTile>
    with LinkingMixin {
  int unseen = 0;

  @override
  Map<ChangeNotifier, VoidCallback> get links => {
        settings.follows: update,
      };

  Future<void> update() async {
    unseen = 0;
    List<Follow> follows = await settings.follows.value;
    for (Follow follow in follows) {
      unseen += (await follow.status).unseen ?? 0;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: unseen != 0,
      leading: Icon(unseen != 0 ? Icons.mark_email_read : Icons.drafts),
      title: Text(
        'Unseen posts',
        style: Theme.of(context).textTheme.subtitle1,
      ),
      subtitle: unseen != 0
          ? TweenAnimationBuilder(
              tween: IntTween(begin: 0, end: unseen),
              duration: defaultAnimationDuration,
              builder: (context, int value, child) {
                return Text('Mark $value posts as seen');
              },
            )
          : Text('No unseen posts'),
      onTap: () async {
        List<Follow> follows = await settings.follows.value;
        for (Follow follow in follows) {
          (await follow.status).unseen = 0;
        }
        settings.follows.value = Future.value(follows);
        Navigator.of(context).maybePop();
      },
    );
  }
}

class FollowSplitSwitchTile extends StatefulWidget {
  const FollowSplitSwitchTile();

  @override
  _FollowSplitSwitchTileState createState() => _FollowSplitSwitchTileState();
}

class _FollowSplitSwitchTileState extends State<FollowSplitSwitchTile>
    with LinkingMixin {
  bool followsSplit = false;

  void update() {
    settings.followsSplit.value
        .then((value) => setState(() => followsSplit = value));
  }

  @override
  Map<ChangeNotifier, VoidCallback> get links => {
        settings.followsSplit: update,
      };

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(followsSplit ? Icons.view_comfy : Icons.view_compact),
      title: Text(
        'Split tags',
        style: Theme.of(context).textTheme.subtitle1,
      ),
      subtitle: followsSplit ? Text('Seperated tags') : Text('Mixed tags'),
      value: followsSplit,
      onChanged: (value) async {
        await Navigator.of(context).maybePop();
        settings.followsSplit.value = Future.value(value);
      },
    );
  }
}

class FollowSettingsTile extends StatelessWidget {
  const FollowSettingsTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.turned_in),
      title: Text(
        'Following settings',
        style: Theme.of(context).textTheme.subtitle1,
      ),
      onTap: () async {
        await Navigator.of(context).maybePop();
        Navigator.of(context).pushNamed('/following');
      },
    );
  }
}
