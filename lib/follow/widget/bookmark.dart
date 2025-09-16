import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class FollowsBookmarkPage extends StatelessWidget {
  const FollowsBookmarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RouterDrawerEntry<FollowsBookmarkPage>(
      child: SubChangeNotifierProvider<Client, FollowController>(
        create: (context, client) =>
            FollowController(client: client, types: [FollowType.bookmark]),
        child: Consumer<FollowController>(
          builder: (context, controller, child) => SubEffect(
            effect: () {
              // remove this when the paged grid view is implemented
              controller.getNextPage();
              final client = context.read<Client>();
              client.followServer.sync();
              return null;
            },
            keys: const [],
            child: SelectionLayout<Follow>(
              items: controller.items,
              child: PromptActions(
                child: RefreshableDataPage.builder(
                  controller: controller,
                  appBar: const FollowSelectionAppBar(
                    child: DefaultAppBar(title: Text('Bookmarks')),
                  ),
                  drawer: const RouterDrawer(),
                  floatingActionButton: AddTagFloatingActionButton(
                    title: 'Add to bookmarks',
                    onSubmit: (value) async {
                      value = value.trim();
                      if (value.isEmpty) return;
                      await context.read<Client>().follows.create(
                        tags: value,
                        type: FollowType.bookmark,
                      );
                    },
                  ),
                  builder: (context, child) =>
                      LimitedWidthLayout(child: TileLayout(child: child)),
                  child: (context) => ListenableBuilder(
                    listenable: controller,
                    builder: (context, _) =>
                        PagedAlignedGridView<int, Follow>.count(
                          primary: true,
                          padding: defaultActionListPadding,
                          addAutomaticKeepAlives: false,
                          state: controller.state,
                          fetchNextPage: controller.getNextPage,
                          builderDelegate: defaultPagedChildBuilderDelegate(
                            onRetry: controller.getNextPage,
                            itemBuilder: (context, item, index) =>
                                FollowTile(follow: item),
                            onEmpty: const Text('No bookmarks'),
                            onError: const Text('Failed to load bookmarks'),
                          ),
                          crossAxisCount: TileLayout.of(context).crossAxisCount,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
