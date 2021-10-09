import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

class PoolFollowButton extends StatefulWidget {
  final Pool pool;

  const PoolFollowButton(this.pool);

  @override
  State<StatefulWidget> createState() {
    return PoolFollowButtonState();
  }
}

class PoolFollowButtonState extends State<PoolFollowButton> {
  late String tag = 'pool:${widget.pool.id}';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Follow>>(
      valueListenable: settings.follows,
      builder: (context, value, child) {
        bool following = value.any((element) => element.tags == tag);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                if (following) {
                  value.removeWhere((element) => element.tags == tag);
                } else {
                  value.add(Follow.fromString(tag));
                }
                settings.follows.value = List.from(value);
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
      },
    );
  }
}
