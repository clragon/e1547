import 'package:e1547/interface.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/pool/pages/info.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

import 'actions.dart';

void poolDialog({@required BuildContext context, @required Pool pool}) {
  showDialog(
    context: context,
    child: PoolDialog(
      pool: pool,
    ),
  );
}

class PoolDialog extends StatelessWidget {
  final Pool pool;

  const PoolDialog({@required this.pool});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Text(
              '${pool.name.replaceAll('_', ' ')} (#${pool.id})',
              softWrap: true,
            ),
          ),
          FollowButton(pool),
        ],
      ),
      content: ConstrainedBox(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                pool.description.isNotEmpty
                    ? DTextField(msg: pool.description)
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
          constraints: BoxConstraints(
            maxHeight: 400.0,
          )),
      actions: [
        FlatButton(
          child: Text('SHARE'),
          onPressed: () async =>
              Share.share(pool.url(await db.host.value).toString()),
        ),
        FlatButton(
          child: Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
