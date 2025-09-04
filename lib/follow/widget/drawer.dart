import 'package:e1547/domain/domain.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:intl/intl.dart';

class FollowMarkReadTile extends StatelessWidget {
  const FollowMarkReadTile({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FollowPageQueryBuilder(
      builder: (context, state, query) {
        final items = state.data?.pages.expand((page) => page).toList() ?? [];
        int unseenCount = items.fold<int>(0, (a, b) => a + (b.unseen ?? 0));

        return MutationBuilder(
          mutation: context.watch<Domain>().follows.useMarkSeen(),
          builder: (context, state, mutate) => ListTile(
            enabled: unseenCount > 0 && !state.isLoading,
            leading: state.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(unseenCount > 0 ? Icons.mark_email_read : Icons.drafts),
            title: const Text('unseen posts'),
            subtitle: unseenCount > 0
                ? TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: unseenCount),
                    duration: defaultAnimationDuration,
                    builder: (context, value, child) {
                      return Text('mark $value posts as seen');
                    },
                  )
                : const Text('no unseen posts'),
            onTap: () {
              Scaffold.of(context).closeEndDrawer();
              mutate(null);
              onTap?.call();
            },
          ),
        );
      },
    );
  }
}

class FollowFilterReadTile extends StatelessWidget {
  const FollowFilterReadTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: context.watch<Settings>().filterUnseenFollows,
      builder: (context, filterUnseenFollows, child) => SwitchListTile(
        value: filterUnseenFollows,
        onChanged: (value) {
          Scaffold.of(context).closeEndDrawer();
          context.read<Settings>().filterUnseenFollows.value = value;
        },
        secondary: Icon(
          filterUnseenFollows ? Icons.mark_email_unread : Icons.email,
        ),
        title: const Text('show unseen first'),
        subtitle: filterUnseenFollows
            ? const Text('filtering for unseen')
            : const Text('all posts shown'),
      ),
    );
  }
}

class FollowEditingTile extends StatelessWidget {
  const FollowEditingTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Edit'),
      leading: const Icon(Icons.edit),
      onTap: () {
        Scaffold.of(context).closeEndDrawer();
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const FollowEditor()));
      },
    );
  }
}

class FollowForceSyncTile extends StatelessWidget {
  const FollowForceSyncTile({super.key});

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    return SubStream<FollowSync?>(
      create: () => domain.followsServer.syncStream,
      keys: [domain],
      builder: (context, syncSnapshot) {
        bool enabled = false;
        FollowSync? sync = syncSnapshot.data;
        if (syncSnapshot.connectionState == ConnectionState.active) {
          enabled = sync == null;
        }
        return StreamBuilder<double>(
          stream: sync?.progress,
          builder: (context, progressSnapshot) => Column(
            children: [
              ListTile(
                title: const Text('Force sync'),
                leading: const Icon(Icons.sync),
                subtitle: (sync?.completed ?? true)
                    ? const Text('sync all follows')
                    : Text(
                        'syncing follows... '
                        '${NumberFormat('0.#%').format(progressSnapshot.data ?? 0)}',
                      ),
                enabled: enabled,
                onTap: () {
                  // Scaffold.of(context).closeEndDrawer();
                  domain.followsServer.sync(force: true);
                },
              ),
              if (sync != null)
                TweenAnimationBuilder(
                  duration: defaultAnimationDuration,
                  tween: Tween<double>(
                    begin: 0,
                    end: progressSnapshot.data ?? 0,
                  ),
                  builder: (context, value, child) =>
                      LinearProgressIndicator(value: value == 0 ? null : value),
                ),
            ],
          ),
        );
      },
    );
  }
}
