import 'dart:async';

import 'package:e1547/domain/domain.dart';
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

    return SubValue<List<StreamSubscription>>(
      create: () {
        final subscriptions = <StreamSubscription>[];

        for (final ids in postIds) {
          final query = domain.posts.useByIds(ids: ids);
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
