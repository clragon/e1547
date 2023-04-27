import 'package:e1547/client/client.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/pool/widgets/info.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

Future<void> poolSheet(BuildContext context, Pool pool) async {
  return showDefaultSlidingBottomSheet(
    context,
    (context, sheetState) => PoolSheet(pool: pool),
  );
}

class PoolSheet extends StatelessWidget {
  const PoolSheet({required this.pool});

  final Pool pool;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      tagToName(pool.name),
                      style: Theme.of(context).textTheme.titleLarge,
                      softWrap: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () async => Share.share(
                    context,
                    context.read<Client>().withHost(pool.link),
                  ),
                  tooltip: 'Share',
                ),
                TagListActions(tag: 'pool:${pool.id}'),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: pool.description.isNotEmpty
                  ? DText(pool.description)
                  : const Text(
                      'no description',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: PoolInfo(pool: pool),
            ),
          ],
        ),
      ),
    );
  }
}
