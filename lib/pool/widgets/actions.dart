import 'package:async_builder/async_builder.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:flutter/material.dart';

class PoolFollowButton extends StatefulWidget {
  const PoolFollowButton(this.pool);

  final Pool pool;

  @override
  State<StatefulWidget> createState() {
    return PoolFollowButtonState();
  }
}

class PoolFollowButtonState extends State<PoolFollowButton> {
  late String tag = 'pool:${widget.pool.id}';

  @override
  Widget build(BuildContext context) {
    return Consumer2<FollowsService, Client>(
      builder: (context, follows, client, child) =>
          SubValueBuilder<Stream<bool>>(
        create: (context) => follows.watchFollows(client.host, tag),
        selector: (context) => [follows, client],
        builder: (context, value) => AsyncBuilder<bool>(
          retain: true,
          stream: value,
          builder: (context, following) => AnimatedSwitcher(
            duration: defaultAnimationDuration,
            child: following == null
                ? const SizedBox.shrink()
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (following) {
                            follows.removeTag(client.host, tag);
                          } else {
                            follows.addTag(client.host, tag);
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
                  ),
          ),
        ),
      ),
    );
  }
}
