import 'package:e1547/client/client.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/pool/widgets/actions.dart';
import 'package:e1547/pool/widgets/info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

void poolDialog({required BuildContext context, required Pool pool}) {
  showDialog(
    context: context,
    builder: (context) {
      return PoolDialog(
        pool: pool,
      );
    },
  );
}

class PoolDialog extends StatelessWidget {
  const PoolDialog({required this.pool});

  final Pool pool;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                '${pool.name.replaceAll('_', ' ')} (#${pool.id})',
                softWrap: true,
              ),
            ),
            PoolFollowButton(pool),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: constraints.maxHeight * 0.5,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (pool.description.isNotEmpty)
                  DText(pool.description)
                else
                  const Text(
                    'no description',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                const Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 8),
                  child: Divider(),
                ),
                PoolInfo(pool: pool),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('SHARE'),
            onPressed: () async =>
                Share.share(context.read<Client>().withHost(pool.link)),
          ),
          TextButton(
            onPressed: Navigator.of(context).maybePop,
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
