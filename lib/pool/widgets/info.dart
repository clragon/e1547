import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PoolInfo extends StatelessWidget {
  const PoolInfo({super.key, required this.pool});

  final Pool pool;

  @override
  Widget build(BuildContext context) {
    Widget textInfoRow(String label, String value) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      );
    }

    return DefaultTextStyle(
      style: TextStyle(
        color: dimTextColor(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          textInfoRow('posts', pool.postIds.length.toString()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('id'),
              InkWell(
                child: Text(
                  '#${pool.id}',
                ),
                onLongPress: () async {
                  ScaffoldMessengerState messenger =
                      ScaffoldMessenger.of(context);
                  Clipboard.setData(ClipboardData(
                    text: pool.id.toString(),
                  ));
                  await Navigator.of(context).maybePop();
                  messenger.showSnackBar(SnackBar(
                    duration: const Duration(seconds: 1),
                    content: Text('Copied pool id #${pool.id}'),
                  ));
                },
              ),
            ],
          ),
          if (pool.activity?.isActive case final isActive?)
            textInfoRow(
              'activity',
              isActive ? 'active' : 'inactive',
            ),
          textInfoRow(
            'created',
            formatDateTime(pool.createdAt.toLocal()),
          ),
          textInfoRow(
            'updated',
            formatDateTime(
              pool.updatedAt.toLocal(),
            ),
          ),
        ],
      ),
    );
  }
}
