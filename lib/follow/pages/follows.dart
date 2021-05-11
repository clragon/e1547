import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/client.dart';
import 'package:e1547/follow.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FollowsPage extends StatefulWidget {
  @override
  _FollowsPageState createState() => _FollowsPageState();
}

class _FollowsPageState extends State<FollowsPage> {
  RefreshController refreshController = RefreshController();
  ScrollController scrollController = ScrollController();
  FollowList follows;
  bool loading = true;
  int progress = 0;
  int tileSize;

  void update() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (this.mounted) {
        setState(() {
          loading = follows == null || tileSize == null;
        });
      }
    });
  }

  void updateTileSize() {
    db.tileSize.value.then((value) {
      tileSize = value;
      update();
    });
  }

  void updateFollows() {
    db.follows.value.then((value) {
      follows = value;
      update();
    });
  }

  Future<void> refreshFollows({bool force = false}) async {
    follows = await db.follows.value;
    update();
    await follows.update(
        onProgress: (progress, max) {
          this.progress = progress;
          update();
        },
        force: force);
    progress = 0;
  }

  double notZero(double value) => value < 1 ? 1 : value;
  int roundedNotZero(double value) => value.round() == 0 ? 1 : value.round();

  int get crossAxisCount {
    return notZero(MediaQuery.of(context).size.width / tileSize).round();
  }

  @override
  void initState() {
    super.initState();
    updateTileSize();
    db.follows.addListener(updateFollows);
    db.host.addListener(updateFollows);
    db.tileSize.addListener(updateTileSize);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await refreshFollows();
      /*
      refreshController.requestRefresh(needCallback: false).then((value) async {
        await refreshFollows();
        refreshController.refreshCompleted();
      });
       */
    });
  }

  @override
  void dispose() {
    super.dispose();
    db.follows.removeListener(updateFollows);
    db.tileSize.removeListener(updateTileSize);
    db.host.removeListener(updateFollows);
  }

  Widget itemBuilder(BuildContext context, int item) {
    Follow follow = follows.follows[item];
    return Card(
      child: FutureBuilder(
        future: follow.status,
        builder: (context, AsyncSnapshot<FollowStatus> snapshot) {
          if (snapshot.hasData) {
            return Stack(
              children: [
                SafeCrossFade(
                  showChild: snapshot.data.latest != null,
                  builder: (context) => Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          snapshot.data.thumbnail != null
                              ? Expanded(
                                  child: Hero(
                                      tag: 'image_${snapshot.data.latest}',
                                      child: CachedNetworkImage(
                                        imageUrl: snapshot.data.thumbnail,
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                        fit: BoxFit.cover,
                                      )),
                                )
                              : Text('no image'),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Spacer(),
                          ClipRect(
                            child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                                child: Container(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Theme.of(context)
                                          .cardColor
                                          .withOpacity(0.6),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  )),
                                  child: Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            if (follow.notification)
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 4),
                                                child: IconShadowWidget(
                                                  Icon(
                                                    Icons.notifications_active,
                                                    size: 16,
                                                    color: Theme.of(context)
                                                        .iconTheme
                                                        .color,
                                                  ),
                                                  shadowColor: Colors.black,
                                                ),
                                              ),
                                            if (snapshot.data.unseen != null &&
                                                snapshot.data.unseen > 0)
                                              Text(() {
                                                String text = snapshot
                                                    .data.unseen
                                                    .toString();
                                                if (snapshot.data.unseen ==
                                                    follows.checkAmount) {
                                                  text += '+';
                                                }
                                                text += ' new post';
                                                if (snapshot.data.unseen > 1) {
                                                  text += 's';
                                                }
                                                return text;
                                              }(),
                                                  style: TextStyle(
                                                      shadows: textShadow)),
                                            Spacer(),
                                            if (follow.tags.split(' ').length >
                                                3)
                                              Text(
                                                '${follow.tags.split(' ').length} tags',
                                                style: TextStyle(
                                                    shadows: textShadow),
                                              ),
                                          ],
                                        ),
                                        Text(
                                          follow.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6
                                              .copyWith(shadows: textShadow),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          softWrap: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                  secondChild: Padding(
                    padding: EdgeInsets.all(4),
                    child: Center(
                      child: Text(
                        follow.title,
                        style: Theme.of(context).textTheme.headline6,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    SearchPage(tags: follow.tags)))),
                  ),
                ),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }

  StaggeredTile tileBuilder(int item) {
    double extra = 0.2;
    return StaggeredTile.count(1, 1 + extra);
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget() {
      return PageLoader(
        onEmpty: Text('No posts'),
        onLoading: Text('Loading posts'),
        onError: Text('Failed to load posts'),
        isError: false,
        isLoading: loading,
        isEmpty: follows?.length == 0,
        child: SafeBuilder(
          showChild: tileSize != null && follows != null,
          builder: (context) => SmartRefresher(
            primary: false,
            scrollController: scrollController,
            controller: refreshController,
            header: ClassicHeader(
              refreshingText: 'Refreshing $progress / ${follows.length}...',
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
            child: StaggeredGridView.countBuilder(
              key: Key('grid_${crossAxisCount}_key'),
              crossAxisCount: crossAxisCount,
              itemCount: follows.length,
              itemBuilder: itemBuilder,
              staggeredTileBuilder: tileBuilder,
              physics: BouncingScrollPhysics(),
            ),
          ),
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
              icon: Icon(Icons.turned_in),
              tooltip: 'Settings',
              onPressed: () => Navigator.pushNamed(context, '/following'),
            )
          ],
        ),
        controller: scrollController,
      ),
      body: bodyWidget(),
    );
  }
}
