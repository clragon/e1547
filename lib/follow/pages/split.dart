import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/client.dart';
import 'package:e1547/follow.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:e1547/wiki.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FollowsSplitPage extends StatefulWidget {
  @override
  _FollowsSplitPageState createState() => _FollowsSplitPageState();
}

class _FollowsSplitPageState extends State<FollowsSplitPage> {
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

  Future<void> updateTileSize() async {
    await db.tileSize.value.then((value) {
      tileSize = value;
      update();
    });
  }

  Future<void> updateFollows() async {
    db.follows.value.then((value) {
      follows = value;
      update();
    });
  }

  Future<void> refreshFollows({bool force = false}) async {
    await updateFollows();
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
      refreshController
          .requestRefresh(
              needCallback: false, duration: Duration(milliseconds: 100))
          .then((value) async {
        await refreshFollows();
        refreshController.refreshCompleted();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    db.follows.removeListener(updateFollows);
    db.host.removeListener(updateFollows);
    db.tileSize.removeListener(updateTileSize);
  }

  Widget itemBuilder(BuildContext context, int item) {
    Follow follow = follows.follows[item];
    return Card(
      child: FutureBuilder(
        future: follow.status,
        builder: (context, AsyncSnapshot<FollowStatus> snapshot) {
          if (snapshot.hasData) {
            Widget image() {
              return Column(
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
              );
            }

            Widget info() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (follow.notification)
                        Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: IconShadowWidget(
                            Icon(
                              Icons.notifications_active,
                              size: 16,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            shadowColor: Colors.black,
                          ),
                        ),
                      if (snapshot.data.unseen != null &&
                          snapshot.data.unseen > 0)
                        Expanded(
                          child: Text(
                            () {
                              String text = snapshot.data.unseen.toString();
                              if (snapshot.data.unseen == follows.checkAmount) {
                                text += '+';
                              }
                              text += ' new post';
                              if (snapshot.data.unseen > 1) {
                                text += 's';
                              }
                              return text;
                            }(),
                            style: TextStyle(shadows: textShadow),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      Spacer(),
                      if (follow.tags.split(' ').length > 2)
                        Text(
                          '${follow.tags.split(' ').length} tags',
                          style: TextStyle(shadows: textShadow),
                          overflow: TextOverflow.ellipsis,
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
              );
            }

            return Stack(
              children: [
                SafeCrossFade(
                  showChild: snapshot.data.latest != null,
                  builder: (context) => Stack(
                    children: [
                      image(),
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
                                    child: info(),
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
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SearchPage(tags: follow.tags))),
                      onLongPress: () => wikiSheet(
                          context: context, tag: tagToName(follow.tags)),
                    ),
                  ),
                ),
              ],
            );
          }
          return SizedBox.shrink();
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
