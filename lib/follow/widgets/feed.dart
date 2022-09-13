import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class FollowsFeed extends StatefulWidget {
  const FollowsFeed({super.key});

  @override
  State<FollowsFeed> createState() => _FollowsFeedState();
}

class _FollowsFeedState extends State<FollowsFeed> with DrawerEntry {
  @override
  Widget build(BuildContext context) {
    return PostsProvider(
      provider: (search, page, force) => context.read<Client>().follows(
            context.read<FollowsService>().items.map((e) => e.tags).toList(),
            page,
            force: force,
          ),
      child: Consumer<PostsController>(
        builder: (context, controller, child) => PostsPage(
          appBar: const DefaultAppBar(
            title: Text('Follows'),
            actions: [ContextDrawerButton()],
          ),
          controller: controller,
          drawerActions: [
            Builder(
              builder: (context) => ListTile(
                title: const Text('Overview'),
                leading: const Icon(Icons.grid_view),
                onTap: () {
                  Scaffold.of(context).closeEndDrawer();
                  Navigator.of(context).pushNamed('/follows');
                },
              ),
            ),
            Builder(
              builder: (context) => ListTile(
                title: const Text('Edit'),
                leading: const Icon(Icons.edit),
                onTap: () {
                  Scaffold.of(context).closeEndDrawer();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TextEditor(
                        title: const Text('Following'),
                        content: context
                            .read<FollowsService>()
                            .items
                            .tags
                            .join('\n'),
                        onSubmit: (context, value) async {
                          List<String> tags = value.split('\n').trim();
                          tags.removeWhere((tag) => tag.isEmpty);
                          context.read<FollowsService>().edit(tags);
                          return null;
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          displayType: PostDisplayType.timeline,
          canSelect: false,
        ),
      ),
    );
  }
}
