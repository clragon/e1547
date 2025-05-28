import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class FollowSelectionAppBar extends StatelessWidget with AppBarBuilderWidget {
  const FollowSelectionAppBar({super.key, required this.child});

  @override
  final PreferredSizeWidget child;

  @override
  Widget build(BuildContext context) {
    final client = context.watch<Client>();
    return SelectionAppBar<Follow>(
      child: child,
      titleBuilder: (context, data) => data.selections.length == 1
          ? Text(data.selections.first.name)
          : Text('${data.selections.length} follows'),
      actionBuilder: (context, data) {
        int unseen = data.selections.fold(0, (a, b) => a + (b.unseen ?? 0));
        bool bookmarked = data.selections.every(
          (e) => e.type == FollowType.bookmark,
        );
        bool notified = data.selections.every(
          (e) => e.type == FollowType.notify,
        );
        return [
          if (PlatformCapabilities.hasNotifications)
            IconButton(
              icon: Icon(
                notified ? Icons.notifications_off : Icons.notifications_active,
              ),
              tooltip: notified
                  ? 'Disable notifications'
                  : 'Enable notifications',
              onPressed: () async {
                data.clear();
                if (notified) {
                  for (final follow in data.selections) {
                    await client.follows.update(
                      id: follow.id,
                      type: FollowType.update,
                    );
                  }
                } else {
                  for (final follow in data.selections) {
                    await client.follows.update(
                      id: follow.id,
                      type: FollowType.notify,
                    );
                  }
                }
              },
            ),
          IconButton(
            icon: Icon(bookmarked ? Icons.person_add : Icons.bookmark),
            tooltip: bookmarked ? 'Subscribe' : 'Bookmark',
            onPressed: () async {
              data.clear();
              if (bookmarked) {
                for (final follow in data.selections) {
                  await client.follows.update(
                    id: follow.id,
                    type: FollowType.update,
                  );
                }
              } else {
                for (final follow in data.selections) {
                  await client.follows.update(
                    id: follow.id,
                    type: FollowType.bookmark,
                  );
                }
              }
            },
          ),
          IconButton(
            icon: Icon(unseen > 0 ? Icons.mark_email_read : Icons.drafts),
            tooltip: unseen > 0
                ? 'mark $unseen posts as seen'
                : 'no unseen posts',
            onPressed: unseen > 0
                ? () async {
                    data.clear();
                    client.follows.markAllSeen(
                      data.selections.map((e) => e.id).toList(),
                    );
                  }
                : null,
          ),
        ];
      },
    );
  }
}
