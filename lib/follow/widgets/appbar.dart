import 'package:e1547/app/app.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class FollowSelectionAppBar extends StatelessWidget with AppBarBuilderWidget {
  const FollowSelectionAppBar({
    super.key,
    required this.service,
    required this.child,
  });

  final FollowsService service;
  @override
  final PreferredSizeWidget child;

  Future<void> update(Iterable<Follow> follows) async {
    await service.transaction(() async {
      for (final follow in follows) {
        await service.replace(follow);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SelectionAppBar<Follow>(
      child: child,
      titleBuilder: (context, data) => data.selections.length == 1
          ? Text(data.selections.first.name)
          : Text('${data.selections.length} follows'),
      actionBuilder: (context, data) {
        int unseen = data.selections.fold(0, (a, b) => a + (b.unseen ?? 0));
        bool bookmarked =
            data.selections.every((e) => e.type == FollowType.bookmark);
        bool notified =
            data.selections.every((e) => e.type == FollowType.notify);
        return [
          if (PlatformCapabilities.hasNotifications)
            IconButton(
              icon: Icon(
                notified ? Icons.notifications_off : Icons.notifications_active,
              ),
              tooltip:
                  notified ? 'Disable notifications' : 'Enable notifications',
              onPressed: () async {
                if (notified) {
                  update(
                    data.selections.map(
                      (e) => e.copyWith(type: FollowType.update),
                    ),
                  );
                } else {
                  update(
                    data.selections.map(
                      (e) => e.copyWith(type: FollowType.notify),
                    ),
                  );
                }
                data.clear();
              },
            ),
          IconButton(
            icon: Icon(bookmarked ? Icons.person_add : Icons.bookmark),
            tooltip: bookmarked ? 'Subscribe' : 'Bookmark',
            onPressed: () async {
              if (bookmarked) {
                update(
                  data.selections.map(
                    (e) => e.copyWith(type: FollowType.update),
                  ),
                );
              } else {
                update(
                  data.selections.map(
                    (e) => e.copyWith(type: FollowType.bookmark),
                  ),
                );
              }
              data.clear();
            },
          ),
          IconButton(
            icon: Icon(unseen > 0 ? Icons.mark_email_read : Icons.drafts),
            tooltip:
                unseen > 0 ? 'mark $unseen posts as seen' : 'no unseen posts',
            onPressed: unseen > 0
                ? () {
                    update(data.selections.map((e) => e.withSeen()));
                    data.clear();
                  }
                : null,
          ),
        ];
      },
    );
  }
}
