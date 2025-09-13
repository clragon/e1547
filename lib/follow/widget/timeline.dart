import 'package:e1547/follow/follow.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class FollowsTimelinePage extends StatelessWidget {
  const FollowsTimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return RouterDrawerEntry<FollowsTimelinePage>(
      child: AdaptiveScaffold(
        appBar: const DefaultAppBar(
          title: Text('Timeline'),
          actions: [ContextDrawerButton()],
        ),
        drawer: const RouterDrawer(),
        endDrawer: const ContextDrawer(
          title: Text('Timeline'),
          children: [FollowEditingTile()],
        ),
        body: AnimatedBuilder(
          animation: context.watch<Settings>().tileSize,
          builder: (context, child) => TileLayout(
            tileSize: context.watch<Settings>().tileSize.value,
            child: FollowTimelineQueryBuilder(
              builder: (context, state, query) => PullToRefresh(
                onRefresh: query.invalidate,
                child: CustomScrollView(
                  primary: true,
                  slivers: [
                    SliverPadding(
                      padding: defaultActionListPadding,
                      sliver: PostTimelineSliver(
                        state: state.paging,
                        fetchNextPage: query.getNextPage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
