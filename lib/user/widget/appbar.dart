import 'package:e1547/app/app.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/ticket/ticket.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';

class UserSliverAppBar extends StatelessWidget {
  const UserSliverAppBar({super.key, required this.user, this.tabs});

  final User user;
  final List<Widget>? tabs;

  @override
  Widget build(BuildContext context) {
    return DefaultSliverAppBar(
      pinned: true,
      expandedHeight: 250,
      flexibleSpace: Builder(
        builder: (context) {
          FlexibleSpaceBarSettings settings = context
              .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;
          double extension =
              (settings.currentExtent - settings.minExtent) /
              settings.maxExtent;
          double? leadingWidth = context
              .findAncestorWidgetOfExactType<SliverAppBar>()
              ?.leadingWidth;
          return FlexibleSpaceBar(
            titlePadding: leadingWidth != null
                ? EdgeInsets.only(left: leadingWidth + 8, bottom: 16)
                : null,
            collapseMode: CollapseMode.pin,
            title: Opacity(
              opacity: 1 - (extension * 6).clamp(0, 1),
              child: Text(user.name),
            ),
            background: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: PostAvatar(id: user.avatarId),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 32),
                  child: Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottom: tabs != null
          ? TabBar(
              labelColor: Theme.of(context).iconTheme.color,
              indicatorColor: Theme.of(context).iconTheme.color,
              tabs: tabs!,
            )
          : null,
      actions: [UserProfileActions(user: user)],
    );
  }
}

class UserProfileActions extends StatelessWidget {
  const UserProfileActions({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final traits = context.watch<Domain>().traits;
    // TODO: this should be a utility method, also used in comments
    final userTag = 'user:${user.id}';
    bool blocked = traits.value.denylist.contains(userTag);
    return PopupMenuButton<VoidCallback>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) => value(),
      itemBuilder: (context) => [
        PopupMenuTile(
          title: 'Browse',
          icon: Icons.open_in_browser,
          value: () async => launch(context.read<Domain>().withHost(user.link)),
        ),
        PopupMenuTile(
          title: 'Report',
          icon: Icons.report,
          value: () => guardWithLogin(
            context: context,
            callback: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UserReportScreen(user: user),
                ),
              );
            },
            error: 'You must be logged in to report users!',
          ),
        ),
        PopupMenuTile(
          title: blocked ? 'Unblock' : 'Block',
          icon: blocked ? Icons.check : Icons.block,
          value: () {
            if (blocked) {
              traits.value = traits.value.copyWith(
                denylist: traits.value.denylist.toList()..remove(userTag),
              );
            } else {
              traits.value = traits.value.copyWith(
                denylist: traits.value.denylist.toList()..add(userTag),
              );
            }
          },
        ),
      ],
    );
  }
}
