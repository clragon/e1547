import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

import 'actions.dart';
import 'info.dart';

void poolDialog({required BuildContext context, required Pool pool}) {
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

  const PoolDialog({required this.pool});

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
                  ? DText(pool.description)
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
          PoolFollowButton(pool),
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
              Share.share(pool.url(settings.host.value).toString()),
        ),
        TextButton(
          child: Text('OK'),
          onPressed: Navigator.of(context).maybePop,
        ),
      ],
    );
  }
}
