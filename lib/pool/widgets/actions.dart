import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class PoolFollowButton extends StatelessWidget {
  const PoolFollowButton(this.pool);

  final Pool pool;

  @override
  Widget build(BuildContext context) {
    String tag = 'pool:${pool.id}';
    return Consumer2<FollowsService, Client>(
      builder: (context, follows, client, child) => SubStream<bool>(
        create: () => follows.watchFollows(client.host, tag),
        keys: [follows, client, tag],
        builder: (context, snapshot) => AnimatedSwitcher(
          duration: defaultAnimationDuration,
          child: snapshot.data == null
              ? const SizedBox.shrink()
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (snapshot.data!) {
                          follows.removeTag(client.host, tag);
                        } else {
                          follows.addTag(client.host, tag);
                        }
                      },
                      icon: CrossFade(
                        showChild: snapshot.data!,
                        secondChild: const Icon(Icons.turned_in_not),
                        child: const Icon(Icons.turned_in),
                      ),
                      tooltip: snapshot.data! ? 'unfollow tag' : 'follow tag',
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
