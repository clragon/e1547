import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class FollowsTimelinePage extends StatelessWidget {
  const FollowsTimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return RouterDrawerEntry<FollowsTimelinePage>(
      child: PostsProvider(
        fetch: (controller, search, page, force) async {
          FollowsService service = context.read<FollowsService>();
          return controller.client.postsByTags(
            (await service.getAll(host: controller.client.host))
                .map((e) => e.tags)
                .toList(),
            page,
            force: force,
            cancelToken: controller.cancelToken,
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
            drawerActions: const [FollowEditingTile()],
            displayType: PostDisplayType.timeline,
            canSelect: false,
          ),
        ),
      ),
    );
  }
}
