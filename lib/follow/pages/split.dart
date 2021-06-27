import 'package:e1547/client.dart';
import 'package:e1547/follow.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/settings.dart';
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
  ScrollController scrollController = ScrollController();
  bool loading = true;
  int progress = 0;

  void update() {
    if (this.mounted) {
      setState(() {
        loading = tileSize == null || follows == null || safe == null;
      });
    }
  }

  Future<void> refreshFollows({bool force = false}) async {
    await followUpdater.update(force: force);
    update();
  }

  Future<void> updateRefresh() async {
    progress = followUpdater.progress.value;
    update();
    if (refreshController.headerMode.value == RefreshStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
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
    super.dispose();
    followUpdater.removeListener(updateRefresh);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    refreshController = RefreshController();
  }

  Widget itemBuilder(BuildContext context, int item) {
    return FollowTile(follow: follows[item], safe: safe);
  }

  StaggeredTile tileBuilder(int item) {
    return StaggeredTile.count(1, 1 * tileHeightFactor);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      Widget page() {
        return PageLoader(
          onEmpty: Text('No follows'),
          onLoading: Text('Loading follows'),
          onError: Text('Failed to load follows'),
          isError: false,
          isLoading: loading,
          isEmpty: follows?.length == 0,
          pageBuilder: (child) => SmartRefresher(
            primary: false,
            scrollController: scrollController,
            controller: refreshController,
            header: ClassicHeader(
              refreshingText:
                  'Refreshing $progress / ${follows?.length ?? '?'}...',
              completeText: 'Refreshed follows!',
            ),
            onRefresh: () async {
              try {
                await refreshFollows(force: true);
                refreshController.refreshCompleted();
              } on DioError {
                refreshController.refreshFailed();
              }
            },
            physics: BouncingScrollPhysics(),
            child: child,
          ),
          builder: (context) => StaggeredGridView.countBuilder(
            key: Key('grid_${[crossAxisCount, safe].join('_')}_key'),
            crossAxisCount: crossAxisCount(constraints.maxWidth),
            itemCount: follows.length,
            itemBuilder: itemBuilder,
            staggeredTileBuilder: tileBuilder,
            physics: BouncingScrollPhysics(),
          ),
        );
      }

      return Scaffold(
        drawer: NavigationDrawer(),
        appBar: ScrollingAppbarFrame(
          child: AppBar(
            title: Text('Following'),
            actions: [
              IconButton(
                icon: Icon(Icons.view_compact),
                tooltip: 'Combine',
                onPressed: () => db.followsSplit.value = Future.value(false),
              ),
              IconButton(
                icon: Icon(Icons.turned_in),
                tooltip: 'Settings',
                onPressed: () => Navigator.pushNamed(context, '/following'),
              )
            ],
          ),
          controller: scrollController,
        ),
        body: page(),
      );
    });
  }
}
