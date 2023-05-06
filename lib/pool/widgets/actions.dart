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
        builder: (context, snapshot) => CrossFade(
          showChild: snapshot.data != null,
          child: Row(
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
                  secondChild: const Icon(Icons.person_add),
                  child: const Icon(Icons.person_remove),
                ),
                tooltip: snapshot.data! ? 'Unfollow pool' : 'Follow pool',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
