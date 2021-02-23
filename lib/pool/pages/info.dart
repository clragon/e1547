import 'package:e1547/pool.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PoolInfo extends StatelessWidget {
  final DateFormat dateFormat = DateFormat('dd.MM.yy HH:mm');
  final Pool pool;

  PoolInfo({@required this.pool});

  @override
  Widget build(BuildContext context) {
    Color textColor =
        Theme.of(context).textTheme.bodyText1.color.withOpacity(0.35);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'posts',
              style: TextStyle(color: textColor),
            ),
            Text(
              pool.postIDs.length.toString(),
              style: TextStyle(color: textColor),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'status',
              style: TextStyle(color: textColor),
            ),
            pool.active
                ? Text(
                    'active',
                    style: TextStyle(color: textColor),
                  )
                : Text(
                    'inactive',
                    style: TextStyle(color: textColor),
                  ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'created',
              style: TextStyle(color: textColor),
            ),
            Text(
              dateFormat.format(DateTime.parse(pool.creation).toLocal()),
              style: TextStyle(color: textColor),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'updated',
              style: TextStyle(color: textColor),
            ),
            Text(
              dateFormat.format(DateTime.parse(pool.updated).toLocal()),
              style: TextStyle(color: textColor),
            ),
          ],
        ),
      ],
    );
  }
}
