import 'dart:math';

import 'package:e1547/domain/domain.dart';
import 'package:e1547/markup/markup.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class PoolTile extends StatelessWidget {
  const PoolTile({super.key, required this.pool, this.onPressed});

  final Pool pool;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    Widget title() {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                tagToName(pool.name),
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              pool.postIds.length.toString(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    Widget? image;

    if (pool.postIds.isNotEmpty) {
      final domain = context.watch<Domain>();
      final thumbnailId = pool.postIds.first;
      final postQuery = Query<Post>(
        cache: domain.storage.queryCache,
        key: ['posts', thumbnailId],
        queryFn: () => domain.posts.get(id: thumbnailId),
        config: QueryConfig(shouldFetch: (_, _, _) => false),
      );

      image = QueryBuilder(
        query: postQuery,
        builder: (context, state) {
          if (state.data == null) return const SizedBox.shrink();
          final post = state.data!;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: AspectRatio(
                aspectRatio: max(post.width / post.height, 0.9),
                child: PostImageTile(post: post),
              ),
            ),
          );
        },
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: AnimatedSize(
                  duration: defaultAnimationDuration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title(),
                      if (pool.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Opacity(
                            opacity: 0.5,
                            child: DText(
                              pool.description.ellipse(
                                image == null ? 400 : 200,
                              ),
                            ),
                          ),
                        ),
                      if (image != null) image,
                    ],
                  ),
                ),
              ),
              Positioned.fill(
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: onPressed,
                    onLongPress: () =>
                        showPoolPrompt(context: context, pool: pool),
                    onSecondaryTap: () =>
                        showPoolPrompt(context: context, pool: pool),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(indent: 8, endIndent: 8),
      ],
    );
  }
}
