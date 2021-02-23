import 'package:e1547/interface.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/pool/pages/info.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

import 'actions.dart';

void poolSheet(BuildContext context, Pool pool) {
  showSlidingBottomSheet(
    context,
    builder: (BuildContext context) {
      return SlidingSheetDialog(
        duration: Duration(milliseconds: 400),
        isBackdropInteractable: true,
        cornerRadius: 16,
        minHeight: MediaQuery.of(context).size.height * 0.6,
        builder: (context, sheetState) {
          return PoolSheet(
            pool: pool,
          );
        },
        snapSpec: SnapSpec(
          snap: true,
          positioning: SnapPositioning.relativeToAvailableSpace,
          snappings: [
            0.6,
            SnapSpec.expanded,
          ],
        ),
      );
    },
  );
}

class PoolSheet extends StatelessWidget {
  final Pool pool;

  PoolSheet({@required this.pool});

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
                      '${pool.name.replaceAll('_', ' ')} (#${pool.id})',
                      style: Theme.of(context).textTheme.headline6,
                      softWrap: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () async =>
                      Share.share(pool.url(await db.host.value).toString()),
                  tooltip: 'Share',
                ),
                FollowButton(pool),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: pool.description.isNotEmpty
                  ? DTextField(msg: pool.description)
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
