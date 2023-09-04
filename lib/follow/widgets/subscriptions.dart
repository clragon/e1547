import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_sub/flutter_sub.dart';

class FollowsSubscriptionsPage extends StatefulWidget {
  const FollowsSubscriptionsPage({super.key});

  @override
  State<FollowsSubscriptionsPage> createState() =>
      _FollowsSubscriptionsPageState();
}

class _FollowsSubscriptionsPageState extends State<FollowsSubscriptionsPage>
    with RouterDrawerEntryWidget {
  bool filterUnseen = false;

  @override
  Widget build(BuildContext context) {
    void update([bool? force]) => context.read<FollowsUpdater>().update(
          client: context.read<Client>(),
          denylist: context.read<DenylistService>().items,
          force: force,
        );

    return Consumer2<FollowsService, Client>(
      builder: (context, service, client, child) => FollowUpdates(
        builder: (context, refreshController) => SubStream<List<Follow>>(
          create: () => filterUnseen
              ? service.unseen(host: client.host).stream
              : service.all(
                  host: client.host,
                  types: [FollowType.update, FollowType.notify],
                ).stream,
          listener: (event) => update(),
          keys: [client, service, filterUnseen],
          builder: (context, snapshot) {
            List<Follow>? follows = snapshot.data;
            return SelectionLayout<Follow>(
              items: follows,
              child: SheetActions(
                child: RefreshableLoadingPage(
                  onEmpty: const Text('No subscriptions'),
                  onError: const Text('Failed to load subscriptions'),
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
                        filterUnseen: filterUnseen,
                        onChanged: (value) =>
                            setState(() => filterUnseen = value),
                      ),
                      FollowMarkReadTile(
                        onTap: () => setState(() => filterUnseen = false),
                      ),
                    ],
                  ),
                  floatingActionButton: SheetFloatingActionButton(
                    builder: (context, actionController) =>
                        ControlledTextWrapper(
                      submit: (value) {
                        value = value.trim();
                        if (value.isNotEmpty) {
                          service.addTag(
                            client.host,
                            value,
                            type: FollowType.update,
                          );
                        }
                      },
                      actionController: actionController,
                      builder: (context, controller, submit) => TagInput(
                        controller: controller,
                        textInputAction: TextInputAction.done,
                        labelText: 'Add to subscriptions',
                        submit: submit,
                      ),
                    ),
                    actionIcon: Icons.add,
                    confirmIcon: Icons.check,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
