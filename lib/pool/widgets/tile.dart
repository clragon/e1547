import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class PoolTile extends StatelessWidget {
  final Pool pool;
  final VoidCallback? onPressed;

  PoolTile({
    required this.pool,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget title() {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  tagToTitle(pool.name),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.subtitle1,
                  maxLines: 1,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                pool.postIds.length.toString(),
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      child: InkWell(
        onTap: this.onPressed,
        onLongPress: () => poolSheet(context, pool),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title(),
            if (pool.description.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 0,
                  bottom: 8,
                ),
                child: IgnorePointer(
                  child: DTextField(source: pool.description, dark: true),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
