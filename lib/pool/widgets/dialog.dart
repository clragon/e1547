import 'package:e1547/dtext.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

import 'actions.dart';
import 'info.dart';

void poolDialog({@required BuildContext context, @required Pool pool}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return PoolDialog(
        pool: pool,
      );
    },
  );
}

class PoolDialog extends StatelessWidget {
  final Pool pool;

  PoolDialog({@required this.pool});

  @override
  Widget build(BuildContext context) {
    Widget body() {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              pool.description.isNotEmpty
                  ? DTextField(source: pool.description)
                  : Text(
                      'no description',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
              Padding(
                padding: EdgeInsets.only(top: 16, bottom: 8),
                child: Divider(),
              ),
              PoolInfo(pool: pool),
            ],
          ),
          physics: BouncingScrollPhysics(),
        ),
      );
    }

    Widget title() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              '${pool.name.replaceAll('_', ' ')} (#${pool.id})',
              softWrap: true,
            ),
          ),
          FollowButton(pool),
        ],
      );
    }

    return AlertDialog(
      title: title(),
      content: body(),
      actions: [
        TextButton(
          child: Text('SHARE'),
          onPressed: () async =>
              Share.share(pool.url(await db.host.value).toString()),
        ),
        TextButton(
          child: Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
