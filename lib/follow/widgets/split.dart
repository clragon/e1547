import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FollowsSplitPage extends StatefulWidget {
  @override
  _FollowsSplitPageState createState() => _FollowsSplitPageState();
}

class _FollowsSplitPageState extends State<FollowsSplitPage>
    with TileSizeMixin, LinkingMixin {
  late RefreshController refreshController;

  @override
  Map<ChangeNotifier, VoidCallback> get links => {
        followUpdater: updateRefresh,
      };

  Future<void> refreshFollows({bool force = false}) async {
    await followUpdater.update(force: force);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> updateRefresh() async {
    if (mounted) {
      if (refreshController.headerMode!.value == RefreshStatus.idle) {
        WidgetsBinding.instance!.addPostFrameCallback((_) async {
          await refreshController.requestRefresh(
            needCallback: false,
            duration: Duration(milliseconds: 100),
          );
          await followUpdater.finish;
          if (!followUpdater.error) {
            refreshController.refreshCompleted();
          } else {
            refreshController.refreshFailed();
          }
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    refreshFollows();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    refreshController = RefreshController();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ValueListenableBuilder<List<Follow>>(
        valueListenable: settings.follows,
        builder: (context, follows, child) => ValueListenableBuilder(
          valueListenable: settings.host,
          builder: (context, host, child) => RefreshablePageLoader(
            onEmpty: Text('No follows'),
            onLoading: Text('Loading follows'),
            onError: Text('Failed to load follows'),
            isError: false,
            isLoading: false,
            isBuilt: true,
            isEmpty: follows.length == 0,
            refreshController: refreshController,
            refreshHeader: ValueListenableBuilder(
              valueListenable: followUpdater.progress,
              builder: (context, progress, child) =>
                  RefreshablePageDefaultHeader(
                refreshingText: 'Refreshing $progress / ${follows.length}...',
              ),
            ),
            builder: (context) => StaggeredGridView.countBuilder(
              key: Key('grid_${[tileSize, client.isSafe].join('_')}_key'),
              addAutomaticKeepAlives: false,
              crossAxisCount: crossAxisCount(constraints.maxWidth),
              itemCount: follows.length,
              itemBuilder: (context, index) =>
                  FollowTile(follow: follows[index], safe: client.isSafe),
              staggeredTileBuilder: (index) =>
                  StaggeredTile.count(1, 1 * tileHeightFactor),
              physics: BouncingScrollPhysics(),
            ),
            appBar: defaultAppBar(title: 'Following'),
            refresh: () async {
              if (await validateCall(() => refreshFollows(force: true))) {
                refreshController.refreshCompleted();
              } else {
                refreshController.refreshFailed();
              }
            },
            drawer: NavigationDrawer(),
            endDrawer: ContextDrawer(
              title: Text('Options'),
              children: [
                FollowSplitSwitchTile(),
                FollowMarkReadTile(),
                Divider(),
                FollowSettingsTile(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
