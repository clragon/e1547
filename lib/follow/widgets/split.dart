import 'package:e1547/client.dart';
import 'package:e1547/follow.dart';
import 'package:e1547/interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FollowsSplitPage extends StatefulWidget {
  @override
  _FollowsSplitPageState createState() => _FollowsSplitPageState();
}

class _FollowsSplitPageState extends State<FollowsSplitPage>
    with FollowerMixin, TileSizeMixin {
  RefreshController refreshController = RefreshController();
  int progress = 0;

  Future<void> refreshFollows({bool force = false}) async {
    await followUpdater.update(force: force);
    setState(() {});
  }

  Future<void> updateRefresh() async {
    setState(() {
      progress = followUpdater.progress.value;
    });
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

  @override
  Future<void> afterFollowInit() async {
    await refreshFollows();
  }

  @override
  void initState() {
    super.initState();
    followUpdater.addListener(updateRefresh);
  }

  @override
  void dispose() {
    followUpdater.removeListener(updateRefresh);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    refreshController = RefreshController();
  }

  Widget itemBuilder(BuildContext context, int item) {
    return FollowTile(follow: follows![item], safe: safe!);
  }

  StaggeredTile tileBuilder(int item) {
    return StaggeredTile.count(1, 1 * tileHeightFactor);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return RefreshablePageLoader(
        onEmpty: Text('No follows'),
        onLoading: Text('Loading follows'),
        onError: Text('Failed to load follows'),
        isError: false,
        isLoading: follows == null,
        isBuilt: [tileSize, safe].every((e) => e != null),
        isEmpty: follows?.length == 0,
        refreshController: refreshController,
        refreshHeader: RefreshablePageDefaultHeader(
          refreshingText: 'Refreshing $progress / ${follows?.length ?? '?'}...',
        ),
        builder: (context) => StaggeredGridView.countBuilder(
          key: Key('grid_${[tileSize, safe].join('_')}_key'),
          addAutomaticKeepAlives: false,
          crossAxisCount: crossAxisCount(constraints.maxWidth),
          itemCount: follows!.length,
          itemBuilder: itemBuilder,
          staggeredTileBuilder: tileBuilder,
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
      );
    });
  }
}
