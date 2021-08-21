import 'package:e1547/pool/pool.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PoolInfo extends StatelessWidget {
  final DateFormat dateFormat = DateFormat('dd.MM.yy HH:mm');
  final Pool pool;

  PoolInfo({required this.pool});

  @override
  Widget build(BuildContext context) {
    Widget textInfoRow(String label, String value) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
          ),
          Text(
            value,
          ),
        ],
      );
    }

    return DefaultTextStyle(
      style: TextStyle(
          color:
              Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.35)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          textInfoRow('posts', pool.postIds.length.toString()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'id',
              ),
              InkWell(
                child: Text(
                  pool.id.toString(),
                ),
                onLongPress: () {
                  Clipboard.setData(ClipboardData(
                    text: pool.id.toString(),
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: Duration(seconds: 1),
                    content: Text('Copied pool ID #${pool.id}'),
                  ));
                },
              ),
            ],
          ),
          textInfoRow(
            'status',
            pool.isActive ? 'active' : 'inactive',
          ),
          textInfoRow('created', dateFormat.format(pool.createdAt.toLocal())),
          textInfoRow(
            'updated',
            dateFormat.format(pool.updatedAt.toLocal()),
          ),
        ],
      ),
    );
  }
}
