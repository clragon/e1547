import 'package:e1547/follow.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

class FollowButton extends StatefulWidget {
  final Pool pool;

  FollowButton(this.pool);

  @override
  State<StatefulWidget> createState() {
    return FollowButtonState();
  }
}

class FollowButtonState extends State<FollowButton> {
  String tag;
  FollowList follows;
  bool following;

  Future<void> update() async {
    await db.follows.value.then((value) => follows = value);
    following = follows.contains(tag);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    tag = 'pool:${widget.pool.id}';
    db.follows.addListener(update);
    update();
  }

  @override
  void dispose() {
    super.dispose();
    db.follows.removeListener(update);
  }

  @override
  Widget build(BuildContext context) {
    if (follows != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            onPressed: () {
              if (following) {
                follows.remove(tag);
              } else {
                follows.add(tag);
              }
            },
            icon: CrossFade(
              showChild: following,
              child: Icon(Icons.turned_in),
              secondChild: Icon(Icons.turned_in_not),
            ),
            tooltip: following ? 'unfollow tag' : 'follow tag',
          ),
        ],
      );
    } else {
      return Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.turned_in_not),
            onPressed: null,
          ),
        ],
      );
    }
  }
}
