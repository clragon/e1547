import 'dart:math';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:like_button/like_button.dart';

class PostsPage extends StatefulWidget {
  final bool canSelect;
  final PostController controller;
  final PreferredSizeWidget Function(BuildContext) appBarBuilder;
  final List<Widget>? drawerActions;

  PostsPage({
    this.canSelect = true,
    required this.controller,
    required this.appBarBuilder,
    this.drawerActions,
  }) : super(key: ObjectKey(controller));

  @override
  State<StatefulWidget> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage>
    with TileSizeMixin, TileStaggerMixin, LinkingMixin {
  ScrollController scrollController = ScrollController();
  Set<Post> selections = Set();

  void updatePage() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (this.mounted) {
        setState(() {
          if (widget.controller.itemList?.isEmpty ?? true) {
            selections.clear();
          }
        });
      }
    });
  }

  @override
  Map<ChangeNotifier, VoidCallback> get links => {
        widget.controller: updatePage,
      };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateTileSize();
    updateStagger();
  }

  Widget itemBuilder(BuildContext context, Post item, int index) {
    void select() {
      if (widget.canSelect) {
        setState(() {
          if (selections.contains(item)) {
            selections.remove(item);
          } else {
            selections.add(item);
          }
        });
      }
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        PostTile(
          post: item,
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PostDetailGallery(
                controller: widget.controller,
                initialPage: index,
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
                opacity: selections.contains(item) ? 1 : 0,
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: Container(
                    color: Colors.black38,
                    child: LayoutBuilder(
                      builder: (context, constraint) => Icon(
                          Icons.check_circle_outline,
                          size: min(constraint.maxHeight, constraint.maxWidth) *
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

  @override
  Widget build(BuildContext context) {
    Widget? floatingActionButton() {
      if (widget.controller.canSearch) {
        return SheetFloatingActionButton(
          actionIcon: Icons.search,
          builder: (context, actionController) => SheetTextWrapper(
            actionController: actionController,
            textController:
                TextEditingController(text: widget.controller.search.value),
            submit: (value) => widget.controller.search.value = sortTags(value),
            builder: (context, controller, submit) => AdvancedTagInput(
              labelText: 'Tags',
              controller: controller,
              submit: submit,
            ),
          ),
        );
      }
    }

    Widget? endDrawer() {
      List<Widget> children = List.from(widget.drawerActions ?? []);
      if (children.isNotEmpty) {
        children.add(Divider());
      }
      children.add(DrawerCounter(controller: widget.controller));
      if (widget.controller.canDeny) {
        children.add(DrawerDenySwitch(controller: widget.controller));
      }
      if (children.isNotEmpty) {
        return ContextDrawer(title: Text('Search'), children: children);
      }
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
                  selections.addAll(widget.controller.itemList!.toSet()))),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.file_download),
              onPressed: () {
                loadingSnackbar(
                    context: context,
                    items: Set.from(selections),
                    process: (post) => post.download(),
                    timeout: Duration(milliseconds: 100));
                setState(selections.clear);
              },
            ),
          ),
          Builder(
            builder: (context) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: LikeButton(
                  isLiked: selections.length > 0 &&
                      selections.every((post) => post.isFavorited),
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
                              if (post.isFavorited) {
                                return post.tryRemoveFav(context);
                              } else {
                                return true;
                              }
                            }
                          : (post) async {
                              if (!post.isFavorited) {
                                return post.tryAddFav(context);
                              } else {
                                return true;
                              }
                            },
                      timeout: Duration(milliseconds: 300),
                    );
                    setState(selections.clear);
                    return !isLiked;
                  },
                ),
              );
            },
          ),
        ],
      );
    }

    Widget selectionScope(Widget child) {
      return WillPopScope(
        onWillPop: () async {
          if (selections.isNotEmpty) {
            setState(() => selections.clear());
            return false;
          } else {
            return true;
          }
        },
        child: child,
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      StaggeredTile? tileBuilder(int item) {
        if (item < widget.controller.itemList!.length) {
          PostFile image = widget.controller.itemList![item].sample;
          double widthRatio = image.width / image.height;
          double heightRatio = image.height / image.width;

          switch (stagger!) {
            case GridState.square:
              return StaggeredTile.count(1, 1 * tileHeightFactor);
            case GridState.vertical:
              return StaggeredTile.count(1, heightRatio);
            case GridState.omni:
              if (crossAxisCount(constraints.maxWidth) == 1) {
                return StaggeredTile.count(1, heightRatio);
              } else {
                return StaggeredTile.count(roundedNotZero(widthRatio),
                    roundedNotZero(heightRatio) * tileHeightFactor);
              }
          }
        }
        return null;
      }

      return selectionScope(PageLoader(
        isBuilt: [tileSize, stagger].every((element) => element != null),
        builder: (context) => RefreshablePage(
          scrollController: scrollController,
          refreshController: widget.controller.refreshController,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Material(
              elevation: Theme.of(context).appBarTheme.elevation ?? 4,
              child: CrossFade(
                showChild: selections.isEmpty,
                child: Builder(builder: widget.appBarBuilder),
                secondChild: selectionAppBar(),
              ),
            ),
          ),
          drawer: NavigationDrawer(),
          endDrawer: endDrawer(),
          floatingActionButton: floatingActionButton(),
          refresh: () => widget.controller.refresh(background: true),
          builder: (BuildContext context) => PagedStaggeredGridView(
            primary: false,
            scrollController: scrollController,
            addAutomaticKeepAlives: false,
            tileBuilder: tileBuilder,
            pagingController: widget.controller,
            crossAxisCount: crossAxisCount(constraints.maxWidth),
            builderDelegate: defaultPagedChildBuilderDelegate(
              itemBuilder: itemBuilder,
              onEmpty: Text('No posts'),
              onLoading: Text('Loading posts'),
              onError: Text('Failed to load posts'),
            ),
          ),
        ),
      ));
    });
  }
}
