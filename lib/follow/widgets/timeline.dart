import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class FollowsTimelinePage extends StatefulWidget {
  const FollowsTimelinePage({super.key});

  @override
  State<FollowsTimelinePage> createState() => _FollowsTimelinePageState();
}

class _FollowsTimelinePageState extends State<FollowsTimelinePage> {
  @override
  Widget build(BuildContext context) {
    return PostsProvider(
      provider: (search, page, force) async {
        Client client = context.read<Client>();
        FollowsService service = context.read<FollowsService>();
        return client.tagPosts(
          (await service.getAll(host: client.host)).map((e) => e.tags).toList(),
          page,
          force: force,
        );
      },
      canSearch: false,
      child: Consumer<PostsController>(
        builder: (context, controller, child) => PostsPage(
          appBar: const DefaultAppBar(
            title: Text('Follows'),
            actions: [ContextDrawerButton()],
          ),
          controller: controller,
          drawerActions: [
            if (context.findAncestorWidgetOfExactType<FollowsSwitcherPage>() !=
                null)
              const FollowSwitcherTile(),
            const FollowEditingTile(),
          ],
          displayType: PostDisplayType.timeline,
          canSelect: false,
        ),
      ),
    );
  }
}
