import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class PoolTile extends StatelessWidget {
  final Pool pool;
  final VoidCallback? onPressed;

  const PoolTile({
    required this.pool,
    this.onPressed,
  });

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

    return Card(
      child: InkWell(
        onTap: onPressed,
        onLongPress: () => poolSheet(context, pool),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    opacity: 0.35,
                    child: DText(pool.description.ellipse(400)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
