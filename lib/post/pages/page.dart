import 'dart:math';

import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/post/pages/search_drawer.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:like_button/like_button.dart';

import 'search_bar.dart';
import 'snackbar.dart';
import 'tile.dart';

class PostsPage extends StatefulWidget {
  final bool canSelect;
  final PreferredSizeWidget Function(BuildContext) appBarBuilder;
  final PostProvider provider;

  PostsPage({
    this.canSelect = true,
    @required this.provider,
    @required this.appBarBuilder,
  });

  @override
  State<StatefulWidget> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  ValueNotifier<bool> isSearching = ValueNotifier(false);
  TextEditingController textController = TextEditingController();
  PersistentBottomSheetController<Tagset> sheetController;

  Set<Post> selections = Set();
  bool loading = true;
  GridState stagger;
  int tileSize;

  void updatePage() {
    if (this.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          if (widget.provider.pages.value.isEmpty ||
              tileSize == null ||
              stagger == null) {
            loading = true;
          } else {
            loading = false;
          }
        });
      });
    }
  }

  void updateStagger() {
    db.stagger.value.then((value) {
      stagger = value;
      updatePage();
    });
  }

  void updateTileSize() {
    db.tileSize.value.then((value) {
      tileSize = value;
      updatePage();
    });
  }

  @override
  void initState() {
    super.initState();
    db.tileSize.addListener(updateTileSize);
    db.stagger.addListener(updateStagger);
    widget.provider.pages.addListener(updatePage);
    widget.provider.posts.addListener(updatePage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateTileSize();
    updateStagger();
  }

  @override
  void didUpdateWidget(PostsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    selections.clear();
    updatePage();
    // hot reload shenanigans
    db.tileSize.removeListener(updateTileSize);
    db.stagger.removeListener(updateStagger);
    db.tileSize.addListener(updateTileSize);
    db.stagger.addListener(updateStagger);
    widget.provider.pages.removeListener(updatePage);
    widget.provider.pages.addListener(updatePage);
    widget.provider.posts.removeListener(updatePage);
    widget.provider.posts.addListener(updatePage);
  }

  @override
  void dispose() {
    super.dispose();
    widget.provider.dispose();
    db.tileSize.removeListener(updateTileSize);
    db.stagger.removeListener(updateStagger);
    widget.provider.pages.removeListener(updatePage);
    widget.provider.posts.removeListener(updatePage);
  }

  double notZero(double value) => value < 1 ? 1 : value;
  int roundedNotZero(double value) => value.round() == 0 ? 1 : value.round();

  int get crossAxisCount {
    return notZero(MediaQuery.of(context).size.width / tileSize).round();
  }

  Widget itemBuilder(BuildContext context, int item) {
    Widget preview(Post post, PostProvider provider) {
      void select() {
        if (widget.canSelect) {
          setState(() {
            if (selections.contains(post)) {
              selections.remove(post);
            } else {
              selections.add(post);
            }
          });
        }
      }

      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            child: PostTile(
                post: post,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
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
                  duration: defaultAnimationDuration,
                  opacity: selections.contains(post) ? 1 : 0,
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Container(
                      color: Colors.black38,
                      child: LayoutBuilder(
                        builder: (context, constraint) => Icon(
                            Icons.check_circle_outline,
                            size:
                                min(constraint.maxHeight, constraint.maxWidth) *
                                    0.4),
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

  StaggeredTile tileBuilder(int item) {
    if (item < widget.provider.posts.value.length) {
      double extra = 0.2;
      PostImage sample = widget.provider.posts.value[item].sample.value;
      double heightRatio = notZero(sample.height / sample.width);
      double widthRatio = notZero(sample.width / sample.height);

      switch (stagger) {
        case GridState.square:
          return StaggeredTile.count(1, 1 + extra);
        case GridState.vertical:
          return StaggeredTile.count(1, heightRatio);
          break;
        case GridState.omni:
          if (crossAxisCount == 1) {
            return StaggeredTile.count(1, heightRatio);
          } else {
            return StaggeredTile.count(
                roundedNotZero(widthRatio),
                roundedNotZero(heightRatio) +
                    roundedNotZero(heightRatio) * extra);
          }
          break;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Widget floatingActionButton() {
      return Builder(builder: (context) {
        if (widget.provider.canSearch) {
          return ValueListenableBuilder(
            valueListenable: isSearching,
            builder: (BuildContext context, value, Widget child) {
              void submit(String result) {
                widget.provider.search.value = result;
                sheetController?.close();
              }

              return FloatingActionButton(
                heroTag: 'float',
                child: Icon(value ? Icons.check : Icons.search),
                onPressed: () async {
                  selections.clear();
                  if (isSearching.value) {
                    submit(textController.text);
                  } else {
                    textController.text = widget.provider.search.value + ' ';
                    isSearching.value = true;
                    sheetController = Scaffold.of(context).showBottomSheet(
                      (context) => PostSearchBar(
                        controller: textController,
                        onSubmit: submit,
                      ),
                    );
                    isSearching.value = true;
                    sheetController.closed.then((a) {
                      isSearching.value = false;
                    });
                  }
                },
              );
            },
          );
        } else {
          return SizedBox.shrink();
        }
      }).build(context);
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
              onPressed: () => setState(() =>
                  selections.addAll(widget.provider.posts.value.toSet()))),
          Builder(
              builder: (context) => IconButton(
                  icon: Icon(Icons.file_download),
                  onPressed: () {
                    loadingSnackbar(
                        context: context,
                        items: Set.from(selections),
                        process: (post) => post.downloadDialog(context),
                        timeout: Duration(milliseconds: 100));
                    setState(() => selections.clear());
                  })),
          Builder(
            builder: (context) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: LikeButton(
                  isLiked: selections.length > 0 &&
                      selections.every((post) => post.isFavorite.value),
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
                      loadingSnackbar(
                          context: context,
                          items: Set.from(selections),
                          process: (post) async {
                            if (post.isFavorite.value) {
                              return post.tryRemoveFav(context);
                            } else {
                              return true;
                            }
                          },
                          timeout: Duration(milliseconds: 800));
                      setState(() => selections.clear());
                      return false;
                    } else {
                      loadingSnackbar(
                          context: context,
                          items: Set.from(selections),
                          process: (post) async {
                            if (!post.isFavorite.value) {
                              return post.tryAddFav(context);
                            } else {
                              return true;
                            }
                          },
                          timeout: Duration(milliseconds: 800));
                      setState(() => selections.clear());
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

    Widget body() {
      if (tileSize != null && stagger != null) {
        return StaggeredGridView.countBuilder(
          key: Key('grid_${crossAxisCount}_${stagger}_key'),
          crossAxisCount: crossAxisCount,
          itemCount: widget.provider.posts.value.length,
          itemBuilder: itemBuilder,
          staggeredTileBuilder: tileBuilder,
          physics: BouncingScrollPhysics(),
        );
      } else {
        return SizedBox.shrink();
      }
    }

    return WillPopScope(
      onWillPop: () async {
        if (selections.isNotEmpty) {
          setState(() => selections.clear());
          return false;
        } else {
          return true;
        }
      },
      child: RefreshablePage.builder(
        builder: (context, child, scrollController) => Scaffold(
          appBar: ScrollingAppbarFrame(
            child: Material(
              elevation: Theme.of(context).appBarTheme.elevation ?? 4,
              child: CrossFade(
                showChild: selections.isEmpty,
                child: widget.appBarBuilder(context),
                secondChild: selectionAppBar(),
              ),
            ),
            controller: selections.isEmpty ? scrollController : null,
          ),
          body: child,
          drawer: NavigationDrawer(),
          endDrawer: widget.provider.canDeny
              ? SearchDrawer(provider: widget.provider)
              : null,
          floatingActionButton: floatingActionButton(),
        ),
        child: body(),
        refresh: () async {
          await widget.provider.loadNextPage(reset: true);
          selections.clear();
        },
        isLoading: loading,
        isEmpty: widget.provider.posts.value.isEmpty,
        onLoading: Text('Loading posts'),
        onEmpty: Text('No posts'),
      ),
    );
  }
}

AppBar Function(BuildContext context) defaultAppBar(String title) {
  return (context) {
    return AppBar(
      title: Text(title),
      actions: [SizedBox.shrink()],
    );
  };
}
