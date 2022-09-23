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
          drawerActions: const [
            FollowSwitcherTile(),
            FollowEditingTile(),
          ],
          displayType: PostDisplayType.timeline,
          canSelect: false,
        ),
      ),
    );
  }
}
