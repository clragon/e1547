import 'dart:math';

import 'package:collection/collection.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class PoolTile extends StatelessWidget {
  const PoolTile({
    required this.pool,
    this.onPressed,
  });

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
                style: Theme.of(context).textTheme.subtitle1,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              pool.postIds.length.toString(),
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
      );
    }

    Widget? image;
    PoolsController? controller = context.watch<PoolsController?>();

    if (pool.postIds.isNotEmpty && controller != null) {
      int thumbnail = pool.postIds.first;
      Post? post = controller.thumbnails.itemList
          ?.firstWhereOrNull((e) => e.id == thumbnail);
      if (post != null) {
        image = ChangeNotifierProvider<PostsController>.value(
          value: controller.thumbnails,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: AspectRatio(
              aspectRatio: max(post.file.width / post.file.height, 0.9),
              child: PostImageTile(post: post),
            ),
          ),
        );
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: InkWell(
            onTap: onPressed,
            onLongPress: () => poolSheet(context, pool),
            child: Padding(
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
                        child: IgnorePointer(
                          child: Opacity(
                            opacity: 0.5,
                            child: DText(
                              pool.description.ellipse(
                                image == null ? 400 : 200,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (image != null) image,
                  ],
                ),
              ),
            ),
          ),
        ),
        const Divider(indent: 8, endIndent: 8),
      ],
    );
  }
}
