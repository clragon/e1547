import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

class FollowMarkReadTile extends StatefulWidget {
  const FollowMarkReadTile();

  @override
  _FollowMarkReadTileState createState() => _FollowMarkReadTileState();
}

class _FollowMarkReadTileState extends State<FollowMarkReadTile>
    with LinkingMixin {
  late List<Follow> follows;
  late int unseen;

  @override
  Map<ChangeNotifier, VoidCallback> get initLinks => {
        settings.follows: update,
      };

  Future<void> update() async {
    unseen = 0;
    follows = List.from(settings.follows.value);
    for (Follow follow in follows) {
      unseen += follow.status.unseen ?? 0;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled: unseen != 0,
      leading: Icon(unseen != 0 ? Icons.mark_email_read : Icons.drafts),
      title: Text('unseen posts'),
      subtitle: unseen != 0
          ? TweenAnimationBuilder(
              tween: IntTween(begin: 0, end: unseen),
              duration: defaultAnimationDuration,
              builder: (context, int value, child) {
                return Text('mark $value posts as seen');
              },
            )
          : Text('no unseen posts'),
      onTap: () async {
        for (Follow follow in follows) {
          follow.status.unseen = 0;
        }
        settings.follows.value = follows;
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

class _FollowSplitSwitchTileState extends State<FollowSplitSwitchTile> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: settings.splitFollows,
      builder: (context, value, child) => SwitchListTile(
        secondary: Icon(value ? Icons.view_comfy : Icons.view_compact),
        title: Text('split tags'),
        subtitle: value ? Text('separated') : Text('combined'),
        value: value,
        onChanged: (value) async {
          await Navigator.of(context).maybePop();
          settings.splitFollows.value = value;
        },
      ),
    );
  }
}

class FollowSettingsTile extends StatelessWidget {
  const FollowSettingsTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.turned_in),
      title: Text('Following settings'),
      onTap: () async {
        await Navigator.of(context).maybePop();
        Navigator.of(context).pushNamed('/following');
      },
    );
  }
}
