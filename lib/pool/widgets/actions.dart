import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
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
    return AnimatedBuilder(
      animation: followController,
      builder: (context, child) {
        bool following =
            followController.items.any((element) => element.tags == tag);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                if (following) {
                  followController.removeTag(tag);
                } else {
                  followController.addTag(tag);
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
      },
    );
  }
}
