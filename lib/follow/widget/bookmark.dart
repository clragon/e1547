import 'package:e1547/domain/domain.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class FollowsBookmarkPage extends StatelessWidget {
  const FollowsBookmarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    return RouterDrawerEntry<FollowsBookmarkPage>(
      child: ListenableProvider(
        create: (_) => FollowParams()..types = {FollowType.bookmark},
        child: PromptActions(
          child: AdaptiveScaffold(
            appBar: const FollowSelectionAppBar(
              child: DefaultAppBar(title: Text('Bookmarks')),
            ),
            drawer: const RouterDrawer(),
            body: const FollowList(),
            floatingActionButton: MutationBuilder(
              mutation: domain.follows.useCreate(),
              builder: (context, state, mutate) => AddTagFloatingActionButton(
                title: 'Add to bookmarks',
                onSubmit: (value) {
                  value = value.trim();
                  if (value.isEmpty) return;
                  mutate(FollowRequest(tags: value, type: FollowType.bookmark));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
