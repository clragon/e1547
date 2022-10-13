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
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  tagToTitle(pool.name),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.subtitle1,
                  maxLines: 1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 16),
              child: Text(
                pool.postIds.length.toString(),
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
          ],
        ),
      );
    }

    Widget? image;
    ExtraPostsController? controller = context.watch<ExtraPostsController?>();

    if (pool.postIds.isNotEmpty && controller != null) {
      int thumbnail = pool.postIds.first;
      if (controller.ids?.contains(thumbnail) ?? false) {
        if (controller.itemList?.firstWhereOrNull((e) => e.id == thumbnail) !=
            null) {
          image = PostProvider(
            id: thumbnail,
            parent: controller,
            child: Consumer<PostController>(
              builder: (context, controller, child) => PostImageTile(
                controller: controller,
              ),
            ),
          );
        }
      }
    }

    return Card(
      child: InkWell(
        onTap: onPressed,
        onLongPress: () => poolSheet(context, pool),
        child: AnimatedSize(
          duration: defaultAnimationDuration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 300,
                ),
                child: image ?? const SizedBox.shrink(),
              ),
              title(),
              if (pool.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}
