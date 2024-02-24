import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_sub/flutter_sub.dart';

class FollowsSubscriptionsPage extends StatelessWidget {
  const FollowsSubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    void update([bool? force]) => context.read<FollowsUpdater>().update(
          client: context.read<Client>(),
          force: force,
        );

    return RouterDrawerEntry<FollowsSubscriptionsPage>(
      child: ValueListenableBuilder(
        valueListenable: context.watch<Settings>().filterUnseenFollows,
        builder: (context, filterUnseenFollows, child) =>
            Consumer<FollowsService>(
          builder: (context, service, child) => FollowUpdates(
            builder: (context, refreshController) => SubStream<List<Follow>>(
              create: () => filterUnseenFollows
                  ? service.unseen().stream.asyncExpand((event) {
                      if (event.fold(0, (a, b) => a + b.unseen!) == 0) {
                        return service.all(
                          types: [FollowType.update, FollowType.notify],
                        ).stream;
                      } else {
                        return Stream.value(event);
                      }
                    })
                  : service.all(
                      types: [FollowType.update, FollowType.notify],
                    ).stream,
              listener: (event) => update(),
              keys: [service, filterUnseenFollows],
              builder: (context, snapshot) {
                List<Follow>? follows = snapshot.data;
                return SelectionLayout<Follow>(
                  items: follows,
                  child: PromptActions(
                    child: RefreshableLoadingPage(
                      onEmpty: const IconMessage(
                        icon: Icon(Icons.clear),
                        title: Text('No subscriptions'),
                      ),
                      onError: const IconMessage(
                        icon: Icon(Icons.warning_amber),
                        title: Text('Failed to load subscriptions'),
                      ),
                      isError: snapshot.hasError,
                      isBuilt: follows != null,
                      isLoading: follows == null,
                      isEmpty: follows?.isEmpty ?? false,
                      refreshController: refreshController,
                      refreshHeader: SubStream<int>(
                        create: () => context.read<FollowsUpdater>().remaining,
                        keys: [context.watch<FollowsUpdater>()],
                        builder: (context, snapshot) =>
                            RefreshablePageDefaultHeader(
                          refreshingText:
                              'Refreshing ${snapshot.data ?? 0} follows...',
                        ),
                      ),
                      builder: (context, child) => TileLayout(child: child),
                      child: (context) => AlignedGridView.count(
                        primary: true,
                        padding: defaultActionListPadding,
                        addAutomaticKeepAlives: false,
                        itemCount: follows?.length ?? 0,
                        itemBuilder: (context, index) => FollowTile(
                          follow: follows![index],
                        ),
                        crossAxisCount: TileLayout.of(context).crossAxisCount,
                      ),
                      appBar: FollowSelectionAppBar(
                        service: service,
                        child: const DefaultAppBar(
                          title: Text('Subscriptions'),
                          actions: [ContextDrawerButton()],
                        ),
                      ),
                      refresh: (refreshController) => update(true),
                      drawer: const RouterDrawer(),
                      endDrawer: ContextDrawer(
                        title: const Text('Subscriptions'),
                        children: [
                          const FollowEditingTile(),
                          const Divider(),
                          FollowFilterReadTile(
                            filterUnseen: filterUnseenFollows,
                            onChanged: (value) => context
                                .read<Settings>()
                                .filterUnseenFollows
                                .value = value,
                          ),
                          const FollowMarkReadTile(),
                        ],
                      ),
                      floatingActionButton: AddTagFloatingActionButton(
                        title: 'Add to subscriptions',
                        onSubmit: (value) {
                          value = value.trim();
                          if (value.isNotEmpty) {
                            service.addTag(
                              value,
                              type: FollowType.update,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
