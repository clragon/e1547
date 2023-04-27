import 'dart:async';

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
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => update(),
    );
  }

  Future<void> update([bool? force]) async =>
      context.read<FollowsUpdater>().update(
            client: context.read<Client>(),
            denylist: context.read<DenylistService>().items,
            force: force,
          );

  Future<void> updateRefresh() async {
    FollowsUpdater updater = context.read<FollowsUpdater>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (updater.remaining > 0 && mounted) {
        if (refreshController.headerMode?.value == RefreshStatus.idle) {
          await refreshController.requestRefresh(
            needCallback: false,
            duration: const Duration(milliseconds: 100),
          );
          await updater.finish;
          if (mounted) {
            ScrollController scrollController =
                PrimaryScrollController.of(context);
            if (scrollController.hasClients) {
              scrollController.animateTo(
                0,
                duration: defaultAnimationDuration,
                curve: Curves.easeInOut,
              );
            }
            if (updater.error == null) {
              refreshController.refreshCompleted();
            } else {
              refreshController.refreshFailed();
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FollowsService, Client>(
      builder: (context, service, client, child) => SubListener(
        listenable: context.watch<FollowsUpdater>(),
        listener: updateRefresh,
        child: SubStream<List<Follow>>(
          create: () {
            Stream<List<Follow>> stream = filterUnseen
                ? service.watchUnseen(host: client.host)
                : service.watchAll(host: client.host);
            stream.listen((event) => update());
            return stream;
          },
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
                  refreshHeader: RefreshablePageDefaultHeader(
                    refreshingText:
                        'Refreshing ${context.watch<FollowsUpdater>().remaining} follows...',
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
                  refresh: (refreshController) async {
                    try {
                      await update(true);
                      refreshController.refreshCompleted();
                    } on ClientException {
                      refreshController.refreshFailed();
                    }
                  },
                  drawer: const RouterDrawer(),
                  endDrawer: ContextDrawer(
                    title: const Text('Follows'),
                    children: [
                      if (context.findAncestorWidgetOfExactType<
                              FollowsSwitcherPage>() !=
                          null)
                        const FollowSwitcherTile(),
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
