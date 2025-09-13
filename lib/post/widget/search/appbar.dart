import 'package:e1547/domain/domain.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class PostPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PostPageAppBar({super.key, this.actions});

  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final params = context.watch<PostParams>();
    final tags = params.tags ?? '';

    final poolMatch = poolRegex().firstMatch(tags);
    final poolId = poolMatch?.namedGroup('id');

    if (poolId != null) {
      return PoolAppBar(id: int.parse(poolId), actions: actions);
    } else {
      return _TagBasedAppBar(tags: tags, actions: actions);
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TagBasedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _TagBasedAppBar({required this.tags, this.actions});

  final String tags;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();

    String title;
    bool showInfo = false;

    // TODO: if Follow matches, replace title

    final map = TagMap(tags);
    if (map.isEmpty) {
      title = 'Search';
    } else if (map['order'] == 'rank') {
      title = 'Hot';
    } else if (map['fav'] != null) {
      final username = map['fav']!;
      if (username == domain.persona.identity.username) {
        title = 'Favorites';
      } else {
        title = '${nameToPretty(username)}\'s Favorites';
      }
    } else {
      title = tagToName(map.toString());
      showInfo = true;
    }

    return DefaultAppBar(
      title: Text(title),
      actions: [
        if (showInfo)
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => showTagSearchPrompt(context: context, tag: tags),
          ),
        ...?actions,
        const ContextDrawerButton(),
      ],
    );
  }
}
