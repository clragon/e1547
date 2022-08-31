import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FollowsSplitPage extends StatefulWidget {
  const FollowsSplitPage({super.key});

  @override
  State<FollowsSplitPage> createState() => _FollowsSplitPageState();
}

class _FollowsSplitPageState extends State<FollowsSplitPage> with DrawerEntry {
  final RefreshController refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<FollowsService>().update());
  }

  Future<void> updateRefresh() async {
    FollowsService follows = context.read<FollowsService>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (follows.updating && mounted) {
        if (refreshController.headerMode?.value == RefreshStatus.idle) {
          await refreshController.requestRefresh(
            needCallback: false,
            duration: const Duration(milliseconds: 100),
          );
          await follows.finish;
          if (mounted) {
            ScrollController? scrollController =
                PrimaryScrollController.of(context);
            if (scrollController?.hasClients ?? false) {
              scrollController?.animateTo(
                0,
                duration: defaultAnimationDuration,
                curve: Curves.easeInOut,
              );
            }
            if (follows.error == null) {
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
    return Consumer<FollowsService>(
      builder: (context, follows, child) => ListenableListener(
        listener: updateRefresh,
        listenable: follows,
        child: TileLayout(
          tileHeightFactor: 1.55,
          child: AnimatedBuilder(
            animation: follows,
            builder: (context, child) => RefreshablePageLoader(
              onEmpty: const Text('No follows'),
              onLoading: const Text('Loading follows'),
              onError: const Text('Failed to load follows'),
              isError: false,
              isLoading: false,
              isEmpty: follows.items.isEmpty,
              refreshController: refreshController,
              refreshHeader: RefreshablePageDefaultHeader(
                refreshingText:
                    'Refreshing ${follows.progress} / ${follows.items.length}...',
              ),
              builder: (context) => GridView.builder(
                padding: defaultListPadding,
                addAutomaticKeepAlives: false,
                itemCount: follows.items.length,
                itemBuilder: (context, index) =>
                    FollowTile(follow: follows.items[index]),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: TileLayout.of(context).crossAxisCount,
                  childAspectRatio: 1 / TileLayout.of(context).tileHeightFactor,
                ),
              ),
              appBar: const DefaultAppBar(
                title: Text('Following'),
                actions: [ContextDrawerButton()],
              ),
              refresh: () async {
                try {
                  await follows.update(force: true);
                  refreshController.refreshCompleted();
                } on DioError {
                  refreshController.refreshFailed();
                }
              },
              drawer: const NavigationDrawer(),
              endDrawer: const ContextDrawer(
                title: Text('Follows'),
                children: [
                  FollowMarkReadTile(),
                  Divider(),
                  FollowSettingsTile(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
