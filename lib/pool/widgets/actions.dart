import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

class PoolFollowButton extends StatefulWidget {
  final Pool pool;

  PoolFollowButton(this.pool);

  @override
  State<StatefulWidget> createState() {
    return PoolFollowButtonState();
  }
}

class PoolFollowButtonState extends State<PoolFollowButton> with LinkingMixin {
  late String tag = 'pool:${widget.pool.id}';
  List<Follow>? follows;
  late bool following;

  @override
  Map<ChangeNotifier, VoidCallback> get initLinks => {
        settings.follows: update,
      };

  void update() {
    follows = settings.follows.value;
    setState(() {
      following = follows!.any((element) => element.tags == tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (follows != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              if (following) {
                follows!.removeWhere((element) => element.tags == tag);
              } else {
                follows!.add(Follow.fromString(tag));
              }
              settings.follows.value = follows!;
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
        children: [
          IconButton(
            icon: Icon(Icons.turned_in_not),
            onPressed: null,
          ),
        ],
      );
    }
  }
}
