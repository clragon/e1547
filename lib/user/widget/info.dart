import 'package:e1547/markup/markup.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserInfo extends StatelessWidget {
  const UserInfo({super.key, required this.user, this.compact = true});

  final User user;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    Widget info(
      IconData icon,
      String title,
      Object? value, {
      VoidCallback? onLongPress,
    }) {
      if (value == null) return const SizedBox();
      return UserInfoTile(
        icon: icon,
        title: title,
        value: value.toString(),
        onLongPress: onLongPress,
        compact: compact,
      );
    }

    return Expandables(
      expanded: true,
      child: Builder(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.about?.bio case final bio? when bio.isNotEmpty)
              Card(
                child: ExpandablePanel(
                  controller: Expandables.of(context, 'about'),
                  header: const ListTile(
                    leading: Icon(Icons.person),
                    title: Text('About'),
                  ),
                  collapsed: const SizedBox.shrink(),
                  expanded: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: DText(bio),
                  ),
                ),
              ),
            if (user.about?.comission case final comission?
                when comission.isNotEmpty)
              Card(
                child: ExpandablePanel(
                  controller: Expandables.of(context, 'comission'),
                  header: const ListTile(
                    leading: Icon(Icons.attach_money),
                    title: Text('Comission'),
                  ),
                  collapsed: const SizedBox.shrink(),
                  expanded: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: DText(comission),
                  ),
                ),
              ),
            Card(
              child: ExpandablePanel(
                controller: Expandables.of(context, 'info'),
                header: const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Info'),
                ),
                collapsed: const SizedBox.shrink(),
                expanded: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      info(
                        Icons.tag,
                        'id',
                        user.id.toString(),
                        onLongPress: () {
                          Clipboard.setData(
                            ClipboardData(text: user.id.toString()),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 1),
                              content: Text('Copied user id #${user.id}'),
                            ),
                          );
                        },
                      ),
                      if (user.stats case final stats?) ...[
                        info(
                          Icons.calendar_today,
                          'joined',
                          stats.createdAt != null
                              ? DateFormatting.named(stats.createdAt!)
                              : null,
                        ),
                        info(
                          Icons.shield,
                          'rank',
                          stats.levelString?.toLowerCase(),
                        ),
                        info(Icons.upload, 'posts', stats.postUploadCount),
                        info(Icons.edit, 'edits', stats.postUpdateCount),
                        info(Icons.favorite, 'favorites', stats.favoriteCount),
                        info(Icons.comment, 'comments', stats.commentCount),
                        info(Icons.forum, 'forum', stats.forumPostCount),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserInfoTile extends StatelessWidget {
  const UserInfoTile({
    super.key,
    required this.value,
    required this.title,
    required this.icon,
    this.onLongPress,
    this.compact = true,
  });

  final String value;
  final String title;
  final IconData icon;
  final VoidCallback? onLongPress;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: Theme.of(context).textTheme.bodySmall!.color,
    );
    final valueStyle = Theme.of(context).textTheme.titleMedium;

    return InkWell(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 16),
            Expanded(
              child: compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: titleStyle),
                        Text(value, style: valueStyle),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: Text(title, style: valueStyle)),
                        const SizedBox(height: 4),
                        Text(value, style: valueStyle),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
