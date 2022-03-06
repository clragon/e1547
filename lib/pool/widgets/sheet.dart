import 'package:e1547/client/client.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

import 'actions.dart';
import 'info.dart';

void poolSheet(BuildContext context, Pool pool) {
  showSlidingBottomSheet(
    context,
    builder: (context) => defaultSlidingSheetDialog(
      context,
      (context, sheetState) => PoolSheet(pool: pool),
    ),
  );
}

class PoolSheet extends StatelessWidget {
  final Pool pool;

  const PoolSheet({required this.pool});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      tagToTitle(pool.name),
                      style: Theme.of(context).textTheme.headline6,
                      softWrap: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () async =>
                      Share.share(pool.url(client.host).toString()),
                  tooltip: 'Share',
                ),
                PoolFollowButton(pool),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: pool.description.isNotEmpty
                  ? DText(pool.description)
                  : Text(
                      'no description',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: PoolInfo(pool: pool),
            ),
          ],
        ),
      ),
    );
  }
}
