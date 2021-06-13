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

class _FollowsSplitPageState extends State<FollowsSplitPage> {
  RefreshController refreshController = RefreshController();
  ScrollController scrollController = ScrollController();
  List<Follow> follows;
  bool loading = true;
  int progress = 0;
  int tileSize;

  void update() {
    if (this.mounted) {
      setState(() {
        loading = follows == null || tileSize == null;
      });
    }
  }

  Future<void> updateTileSize() async {
    await db.tileSize.value.then((value) {
      tileSize = value;
      update();
    });
  }

  Future<void> updateFollows() async {
    db.follows.value.then((value) async {
      follows = List.from(value);
      if (progress == 0 || progress == follows.length) {
        await follows.sortByNew();
      }
      update();
    });
  }

  Future<void> updateProgress() async {
    setState(() {
      progress = followUpdater.progress.value;
    });
  }

  Future<void> refreshFollows({bool force = false}) async {
    await followUpdater.run(force: force);
    await followUpdater.finish;
    update();
  }

  double notZero(double value) => value < 1 ? 1 : value;
  int roundedNotZero(double value) => value.round() == 0 ? 1 : value.round();

  int get crossAxisCount {
    return notZero(MediaQuery.of(context).size.width / tileSize).round();
  }

  Future<void> initialLoad() async {
    await updateTileSize();
    await updateFollows();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      refreshController
          .requestRefresh(
              needCallback: false, duration: Duration(milliseconds: 100))
          .then((_) async {
        await refreshFollows();
        refreshController.refreshCompleted();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    db.follows.addListener(updateFollows);
    db.host.addListener(updateFollows);
    db.tileSize.addListener(updateTileSize);
    followUpdater.progress.addListener(updateProgress);
    initialLoad();
  }

  @override
  void dispose() {
    super.dispose();
    db.follows.removeListener(updateFollows);
    db.host.removeListener(updateFollows);
    db.tileSize.removeListener(updateTileSize);
    followUpdater.progress.removeListener(updateProgress);
  }

  Widget itemBuilder(BuildContext context, int item) {
    return FollowTile(follow: follows[item]);
  }

  StaggeredTile tileBuilder(int item) {
    double extra = 0.2;
    return StaggeredTile.count(1, 1 + extra);
  }

  @override
  Widget build(BuildContext context) {
    Widget body() {
      if (tileSize != null && follows != null) {
        return StaggeredGridView.countBuilder(
          key: Key('grid_${crossAxisCount}_key'),
          crossAxisCount: crossAxisCount,
          itemCount: follows.length,
          itemBuilder: itemBuilder,
          staggeredTileBuilder: tileBuilder,
          physics: BouncingScrollPhysics(),
        );
      } else {
        return SizedBox.shrink();
      }
    }

    Widget page() {
      return PageLoader(
        onEmpty: Text('No follows'),
        onLoading: Text('Loading follows'),
        onError: Text('Failed to load follows'),
        isError: false,
        isLoading: loading,
        isEmpty: follows?.length == 0,
        child: SmartRefresher(
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
          child: body(),
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
  }
}
