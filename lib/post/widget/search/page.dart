import 'package:e1547/domain/domain.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/material.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key, this.query});

  final QueryMap? query;

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    return RouterDrawerEntry<PostsPage>(
      child: FilterControllerProvider(
        create: (_) => PostFilter(domain),
        keys: (_) => [domain],
        child: ListenableProvider(
          create: (_) => PostParams(value: query),
          child: AdaptiveScaffold(
            appBar: const PostSelectionAppBar(child: PostPageAppBar()),
            floatingActionButton: const PostsPageFab(),
            drawer: const RouterDrawer(),
            endDrawer: const ContextDrawer(
              title: Text('Posts'),
              children: [
                DrawerDenySwitch(),
                // DrawerTagCounter(),
              ],
            ),
            body: ListenableBuilder(
              listenable: context.watch<Settings>().tileSize,
              builder: (context, child) => TileLayout(
                tileSize: context.watch<Settings>().tileSize.value,
                child: const PostList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
