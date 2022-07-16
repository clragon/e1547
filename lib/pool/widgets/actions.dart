import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    return Consumer<FollowsService>(
      builder: (context, follows, child) {
        bool following = follows.items.any((element) => element.tags == tag);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                if (following) {
                  follows.removeTag(tag);
                } else {
                  follows.addTag(tag);
                }
              },
              icon: CrossFade(
                showChild: following,
                secondChild: const Icon(Icons.turned_in_not),
                child: const Icon(Icons.turned_in),
              ),
              tooltip: following ? 'unfollow tag' : 'follow tag',
            ),
          ],
        );
      },
    );
  }
}
