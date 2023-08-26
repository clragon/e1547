import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/markup/markup.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/pool/widgets/info.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

Future<void> showPoolPrompt({
  required BuildContext context,
  required Pool pool,
}) async {
  bool isDesktop = [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(Theme.of(context).platform);

  if (isDesktop) {
    return showPoolDialog(context: context, pool: pool);
  } else {
    return showPoolSheet(context: context, pool: pool);
  }
}

Future<void> showPoolSheet({
  required BuildContext context,
  required Pool pool,
}) async {
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
            PoolActions(pool: pool),
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

class PoolActions extends StatelessWidget {
  const PoolActions({
    super.key,
    required this.pool,
  });

  final Pool pool;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ActionButton(
          icon: const Icon(Icons.share),
          label: const Text('share'),
          onTap: () async => Share.share(
            context,
            context.read<Client>().withHost(pool.link),
          ),
        ),
        TagListActions(tag: 'pool:${pool.id}'),
      ],
    );
  }
}

Future<void> showPoolDialog({
  required BuildContext context,
  required Pool pool,
}) {
  return showDialog(
    context: context,
    builder: (context) => PoolDialog(
      pool: pool,
    ),
  );
}

class PoolDialog extends StatelessWidget {
  const PoolDialog({required this.pool});

  final Pool pool;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: SizedBox(
      width: 800,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  tagToName(pool.name),
                  style: Theme.of(context).textTheme.titleLarge,
                  softWrap: true,
                ),
              ),
              PoolActions(pool: pool),
            ],
          ),
          const Divider(indent: 4, endIndent: 4),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: PoolInfo(pool: pool),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
