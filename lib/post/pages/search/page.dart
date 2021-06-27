import 'dart:math';

import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:e1547/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:like_button/like_button.dart';

class PostsPage extends StatefulWidget {
  final bool canSelect;
  final PostProvider provider;
  final PreferredSizeWidget Function(BuildContext) appBarBuilder;

  PostsPage({
    this.canSelect = true,
    @required this.provider,
    @required this.appBarBuilder,
  }) : super(key: ObjectKey(provider));

  @override
  State<StatefulWidget> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage>
    with TileSizeMixin, TileStaggerMixin {
  ValueNotifier<bool> isSearching = ValueNotifier(false);
  TextEditingController textController = TextEditingController();
  PersistentBottomSheetController<Tagset> sheetController;

  Set<Post> selections = Set();

  void updatePage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (this.mounted) {
        setState(() {
          if (widget.provider.posts.value.isEmpty) {
            selections.clear();
          }
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    widget.provider.addListener(updatePage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateTileSize();
    updateStagger();
  }

  @override
  void reassemble() {
    super.reassemble();
    widget.provider.removeListener(updatePage);
    widget.provider.addListener(updatePage);
  }

  @override
  void dispose() {
    super.dispose();
    widget.provider.removeListener(updatePage);
    widget.provider.dispose();
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
          PostTile(
            post: post,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PostDetailGallery(
                  provider: provider,
                  initialPage: provider.posts.value.indexOf(post),
                ),
              ));
            },
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
    return preview(widget.provider.posts.value[item], widget.provider);
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
                        process: (post) => post.download(),
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
                    loadingSnackbar(
                      context: context,
                      items: Set.from(selections),
                      process: isLiked
                          ? (post) async {
                              if (post.isFavorite.value) {
                                return post.tryRemoveFav(context);
                              } else {
                                return true;
                              }
                            }
                          : (post) async {
                              if (!post.isFavorite.value) {
                                return post.tryAddFav(context);
                              } else {
                                return true;
                              }
                            },
                      timeout: Duration(milliseconds: 500),
                    );
                    setState(() => selections.clear());
                    return !isLiked;
                  },
                ),
              );
            },
          ),
        ],
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      StaggeredTile tileBuilder(int item) {
        if (item < widget.provider.posts.value.length) {
          PostImage sample = widget.provider.posts.value[item].sample.value;
          double heightRatio = notZero(sample.height / sample.width);
          double widthRatio = notZero(sample.width / sample.height);

          switch (stagger) {
            case GridState.square:
              return StaggeredTile.count(1, 1 * tileHeightFactor);
            case GridState.vertical:
              return StaggeredTile.count(1, heightRatio);
              break;
            case GridState.omni:
              if (crossAxisCount(constraints.maxWidth) == 1) {
                return StaggeredTile.count(1, heightRatio);
              } else {
                return StaggeredTile.count(roundedNotZero(widthRatio),
                    roundedNotZero(heightRatio) * tileHeightFactor);
              }
              break;
          }
        }
        return null;
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
        child: RefreshablePage.pageBuilder(
          pageBuilder: (context, child, scrollController) => Scaffold(
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
            drawerEdgeDragWidth: defaultDrawerEdge(constraints.maxWidth),
            endDrawer: widget.provider.canDeny
                ? SearchDrawer(provider: widget.provider)
                : null,
            floatingActionButton: floatingActionButton(),
          ),
          refresh: () async {
            await widget.provider.loadNextPage(reset: true);
            return !widget.provider.isError;
          },
          builder: (context) => StaggeredGridView.countBuilder(
            key: Key('grid_${[tileSize, stagger].join('_')}_key'),
            crossAxisCount: crossAxisCount(constraints.maxWidth),
            itemCount: widget.provider.posts.value.length,
            itemBuilder: itemBuilder,
            staggeredTileBuilder: tileBuilder,
            physics: BouncingScrollPhysics(),
          ),
          isLoading:
              widget.provider.isLoading || tileSize == null || stagger == null,
          isEmpty: widget.provider.posts.value.isEmpty,
          isError: widget.provider.isError,
          onEmpty: Text('No posts'),
          onLoading: Text('Loading posts'),
          onError: Text('Failed to load posts'),
        ),
      );
    });
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
