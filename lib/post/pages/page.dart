import 'package:e1547/interface/navigation.dart';
import 'package:e1547/interface/page_loader.dart';
import 'package:e1547/post.dart';
import 'package:e1547/post/pages/search_drawer.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:like_button/like_button.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'search_bar.dart';
import 'tile.dart';

AppBar Function(BuildContext context) appBarWidget(String title) {
  return (context) {
    return AppBar(
      title: Text(title),
      actions: [Container()],
    );
  };
}

class PostsPage extends StatefulWidget {
  final bool canSearch;
  final bool canSelect;
  final bool canDeny;
  final AppBar Function(BuildContext) appBarBuilder;
  final PostProvider provider;

  PostsPage({
    this.canSearch = true,
    this.canSelect = true,
    this.canDeny = true,
    @required this.provider,
    @required this.appBarBuilder,
  });

  @override
  State<StatefulWidget> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  TextEditingController controller = TextEditingController();
  ValueNotifier<bool> isSearching = ValueNotifier(false);
  PersistentBottomSheetController<Tagset> bottomSheetController;

  Set<Post> selections = Set();
  bool loading = true;
  bool staggered;
  int tileSize;

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  void updateLoading() {
    if (this.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          if (widget.provider.pages.value.length == 0 ||
              tileSize == null ||
              staggered == null) {
            loading = true;
          } else {
            loading = false;
          }
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // tileSize is not linked because updating it will break the grid
    db.staggered.addListener(updateLoading);
    widget.provider.pages.addListener(updateLoading);
    widget.provider.posts.addListener(updateLoading);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    db.tileSize.value.then((value) {
      tileSize = value;
      updateLoading();
    });
    db.staggered.value.then((value) {
      staggered = value;
      updateLoading();
    });
  }

  @override
  void didUpdateWidget(PostsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    selections.clear();
    loading = true;
    widget.provider.pages.removeListener(updateLoading);
    widget.provider.posts.removeListener(updateLoading);
    widget.provider.pages.addListener(updateLoading);
    widget.provider.posts.addListener(updateLoading);
  }

  @override
  void dispose() {
    super.dispose();
    widget.provider.dispose();
    db.staggered.removeListener(updateLoading);
    widget.provider.pages.removeListener(updateLoading);
    widget.provider.posts.removeListener(updateLoading);
  }

  int notZero(int value) => value == 0 ? 1 : value;

  Widget _itemBuilder(BuildContext context, int item) {
    Widget preview(Post post, PostProvider provider) {
      void select() {
        if (widget.canSelect) {
          if (selections.contains(post)) {
            selections.remove(post);
          } else {
            selections.add(post);
          }
          setState(() {});
        }
      }

      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            child: PostTile(
                post: post,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute<Null>(
                    builder: (context) => PostDetailGallery(
                      provider: provider,
                      initialPage: provider.posts.value.indexOf(post),
                    ),
                  ));
                }),
          ),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: selections.isNotEmpty ? select : null,
              onLongPress: select,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity: selections.contains(post) ? 1 : 0,
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Container(
                      color: Colors.black38,
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 54,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (item == widget.provider.posts.value.length - 1) {
      widget.provider.loadNextPage();
    }
    if (item < widget.provider.posts.value.length) {
      return preview(widget.provider.posts.value[item], widget.provider);
    }
    return null;
  }

  StaggeredTile Function(int) _staggeredTileBuilder() {
    return (item) {
      if (item < widget.provider.posts.value.length) {
        if (staggered) {
          PostImage sample = widget.provider.posts.value[item].sample.value;
          double heightRatio = (sample.height / sample.width);
          double widthRatio = (sample.width / sample.height);
          if (notZero((MediaQuery.of(context).size.width / tileSize).round()) ==
              1) {
            return StaggeredTile.count(1, heightRatio);
          } else {
            return StaggeredTile.count(
                notZero(widthRatio.round()), notZero(heightRatio.round()));
          }
        } else {
          return StaggeredTile.count(1, 1.2);
        }
      }
      return null;
    };
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget() {
      return PageLoader(
        onLoading: Text('Loading posts'),
        onEmpty: Text('No posts'),
        isLoading: loading,
        isEmpty: (!loading && widget.provider.posts.value.length == 0),
        child: tileSize != null && staggered != null
            ? SmartRefresher(
                controller: refreshController,
                header: ClassicHeader(
                  refreshingText: 'Refreshing...',
                  completeText: 'Refreshed posts!',
                ),
                onRefresh: () async {
                  await widget.provider.loadNextPage(reset: true);
                  refreshController.refreshCompleted();
                  selections.clear();
                },
                physics: BouncingScrollPhysics(),
                child: StaggeredGridView.countBuilder(
                  crossAxisCount: notZero(
                      (MediaQuery.of(context).size.width / tileSize).round()),
                  itemCount: widget.provider.posts.value.length,
                  itemBuilder: _itemBuilder,
                  staggeredTileBuilder: _staggeredTileBuilder(),
                  physics: BouncingScrollPhysics(),
                ))
            : Container(),
      );
    }

    Widget floatingActionButtonWidget() {
      return Builder(builder: (context) {
        if (widget.canSearch) {
          return ValueListenableBuilder(
            valueListenable: isSearching,
            builder: (BuildContext context, value, Widget child) {
              void submit(String result) {
                widget.provider.search.value = result;
                widget.provider.resetPages();
                bottomSheetController?.close();
              }

              return FloatingActionButton(
                heroTag: 'float',
                child: Icon(value ? Icons.check : Icons.search),
                onPressed: () async {
                  selections.clear();
                  if (isSearching.value) {
                    submit(controller.text);
                  } else {
                    controller.text = widget.provider.search.value + ' ';
                    isSearching.value = true;
                    bottomSheetController =
                        Scaffold.of(context).showBottomSheet(
                      (context) => PostSearchBar(
                        controller: controller,
                        onSubmit: submit,
                      ),
                    );
                    isSearching.value = true;
                    bottomSheetController.closed.then((a) {
                      isSearching.value = false;
                    });
                  }
                },
              );
            },
          );
        } else {
          return Container();
        }
      }).build(context);
    }

    Future<void> loadingSnackbar(BuildContext context,
        Future<bool> Function(Post post) process, Duration timeout) async {
      bool cancel = false;
      bool failure = false;
      List<Post> processing = List.from(selections);
      selections.clear();
      ValueNotifier<int> progress = ValueNotifier<int>(0);
      ScaffoldFeatureController controller =
          Scaffold.of(context).showSnackBar(SnackBar(
        content: ValueListenableBuilder(
            valueListenable: progress,
            builder: (BuildContext context, int value, Widget child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        value == processing.length
                            ? failure
                                ? 'Failure'
                                : 'Done'
                            : 'Post #${widget.provider.posts.value[value].id} ($value/${processing.length})',
                        overflow: TextOverflow.visible,
                      ),
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: TweenAnimationBuilder(
                            duration: timeout,
                            builder:
                                (BuildContext context, value, Widget child) {
                              return LinearProgressIndicator(
                                value: (1 / processing.length) * value,
                              );
                            },
                            tween:
                                Tween<double>(begin: 0, end: value.toDouble()),
                          ),
                        ),
                      ),
                      value == processing.length || failure
                          ? Container()
                          : InkWell(
                              child: Text('CANCEL'),
                              onTap: () {
                                cancel = true;
                              },
                            ),
                    ],
                  )
                ],
              );
            }),
        duration: Duration(days: 1),
      ));
      for (Post post in processing) {
        if (await process(post)) {
          await Future.delayed(timeout);
          progress.value++;
          setState(() {});
        } else {
          failure = true;
          progress.value = processing.length;
          break;
        }
        if (cancel) {
          break;
        }
      }
      await Future.delayed(const Duration(milliseconds: 400));
      controller.close();
      setState(() {});
      return;
    }

    Widget selectionAppBar() {
      return AppBar(
        title: Text('selected ${selections.length} posts'),
        leading: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () => setState(selections.clear),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.select_all),
              onPressed: () {
                selections.addAll(widget.provider.posts.value.toSet());
                setState(() {});
              }),
          Builder(
              builder: (context) => IconButton(
                  icon: Icon(Icons.file_download),
                  onPressed: () => loadingSnackbar(
                      context,
                      (post) => post.downloadDialog(context),
                      Duration(milliseconds: 100)))),
          Builder(
            builder: (context) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: LikeButton(
                  isLiked: selections.every((post) => post.isFavorite.value),
                  circleColor: CircleColor(start: Colors.pink, end: Colors.red),
                  bubblesColor: BubblesColor(
                      dotPrimaryColor: Colors.pink,
                      dotSecondaryColor: Colors.red),
                  likeBuilder: (bool isLiked) {
                    return Icon(
                      Icons.favorite,
                      color: isLiked
                          ? Colors.pinkAccent
                          : Theme.of(context).iconTheme.color,
                    );
                  },
                  onTap: (isLiked) async {
                    if (isLiked) {
                      loadingSnackbar(context, (post) async {
                        if (post.isFavorite.value) {
                          return post.tryRemoveFav(context);
                        } else {
                          return true;
                        }
                      }, Duration(milliseconds: 800));
                      return false;
                    } else {
                      loadingSnackbar(context, (post) async {
                        if (!post.isFavorite.value) {
                          return post.tryAddFav(context);
                        } else {
                          return true;
                        }
                      }, Duration(milliseconds: 800));
                      return true;
                    }
                  },
                ),
              );
            },
          ),
        ],
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (selections.length > 0) {
          selections.clear();
          setState(() {});
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: selections.length == 0
            ? widget.appBarBuilder(context)
            : selectionAppBar(),
        body: bodyWidget(),
        drawer: NavigationDrawer(),
        endDrawer:
            widget.canDeny ? SearchDrawer(provider: widget.provider) : null,
        floatingActionButton: floatingActionButtonWidget(),
      ),
    );
  }
}
