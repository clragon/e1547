import 'package:e1547/domain/domain.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class FollowsSubscriptionsPage extends StatelessWidget {
  const FollowsSubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    return RouterDrawerEntry<FollowsSubscriptionsPage>(
      child: ValueListenableBuilder(
        valueListenable: context.watch<Settings>().filterUnseenFollows,
        builder: (context, filterUnseenFollows, child) => ListenableProvider(
          create: (_) => FollowParams()
            ..types = {FollowType.update, FollowType.notify}
            ..hasUnseen = filterUnseenFollows ? true : null,
          child: PromptActions(
            child: AdaptiveScaffold(
              appBar: const FollowSelectionAppBar(
                child: DefaultAppBar(
                  title: Text('Subscriptions'),
                  actions: [ContextDrawerButton()],
                ),
              ),
              drawer: const RouterDrawer(),
              endDrawer: const ContextDrawer(
                title: Text('Subscriptions'),
                children: [
                  FollowEditingTile(),
                  Divider(),
                  FollowFilterReadTile(),
                  FollowMarkReadTile(),
                  Divider(),
                  FollowForceSyncTile(),
                ],
              ),
              body: const FollowList(),
              floatingActionButton: MutationBuilder(
                mutation: domain.follows.useCreate(),
                builder: (context, state, mutate) => AddTagFloatingActionButton(
                  title: 'Add to subscriptions',
                  onSubmit: (value) {
                    value = value.trim();
                    if (value.isEmpty) return;
                    mutate(FollowRequest(tags: value));
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
