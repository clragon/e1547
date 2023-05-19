import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FollowsFolderPage extends StatefulWidget {
  const FollowsFolderPage({super.key});

  @override
  State<FollowsFolderPage> createState() => _FollowsFolderPageState();
}

class _FollowsFolderPageState extends State<FollowsFolderPage>
    with RouterDrawerEntryWidget {
  final RefreshController refreshController = RefreshController();
  bool filterUnseen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => update());
  }

  void update([bool? force]) => context.read<FollowsUpdater>().update(
        client: context.read<Client>(),
        denylist: context.read<DenylistService>().items,
        force: force,
      );

  void onRemaining(int remaining) =>
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          bool collapsed =
              refreshController.headerMode?.value == RefreshStatus.idle;
          if (remaining > 0) {
            if (collapsed) {
              refreshController.requestRefresh(
                needCallback: false,
                duration: const Duration(milliseconds: 100),
              );
            }
          } else {
            if (!collapsed) {
              refreshController.refreshCompleted();
              ScrollController scrollController =
                  PrimaryScrollController.of(context);
              if (scrollController.hasClients) {
                scrollController.animateTo(
                  0,
                  duration: defaultAnimationDuration,
                  curve: Curves.easeInOut,
                );
              }
            }
          }
        },
      );

  void onFailure(Object exception) => refreshController.refreshFailed();

  @override
  Widget build(BuildContext context) {
    return Consumer2<FollowsService, Client>(
      builder: (context, service, client, child) => SubEffect(
        effect: () => context
            .read<FollowsUpdater>()
            .remaining
            .listen(
              onRemaining,
              onError: onFailure,
            )
            .cancel,
        keys: [context.watch<FollowsUpdater>().value],
        child: SubStream<List<Follow>>(
          create: () => filterUnseen
              ? service.watchUnseen(host: client.host)
              : service.watchAll(host: client.host),
          listener: (event) => update(),
          keys: [client, service, filterUnseen],
          builder: (context, snapshot) {
            List<Follow>? follows = snapshot.data;
            return SelectionLayout<Follow>(
              items: follows,
              child: SheetActions(
                child: RefreshableLoadingPage(
                  onEmpty: const Text('No follows'),
                  onError: const Text('Failed to load follows'),
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
                      title: Text('Follows'),
                      actions: [ContextDrawerButton()],
                    ),
                  ),
                  refresh: (refreshController) => update(true),
                  drawer: const RouterDrawer(),
                  endDrawer: ContextDrawer(
                    title: const Text('Follows'),
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
                          service.addTag(client.host, value);
                        }
                      },
                      actionController: actionController,
                      builder: (context, controller, submit) => TagInput(
                        controller: controller,
                        textInputAction: TextInputAction.done,
                        labelText: 'Add to follows',
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
