import 'dart:async';

import 'package:e1547/domain/domain.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class PostThumbnailQueryLoader extends StatelessWidget {
  const PostThumbnailQueryLoader({
    super.key,
    required this.postIds,
    required this.child,
  });

  final List<List<int>> postIds;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();

    final postCache = domain.storage.queryCache.bridge<Post, int>(
      'posts',
      fetch: (id) => domain.posts.get(id: id),
    );

    return SubValue<List<StreamSubscription>>(
      create: () {
        final subscriptions = <StreamSubscription>[];

        for (final ids in postIds) {
          final query = Query(
            cache: domain.storage.queryCache,
            key: [
              'posts',
              {'tags': 'id:${ids.join(',')}'},
            ],
            queryFn: () =>
                domain.posts.byIds(ids: ids).then(postCache.savePage),
          );

          subscriptions.add(query.stream.listen((_) {}));
        }

        return subscriptions;
      },
      keys: [domain, postIds],
      dispose: (subscriptions) {
        for (final subscription in subscriptions) {
          subscription.cancel();
        }
      },
      builder: (context, _) => child,
    );
  }
}
