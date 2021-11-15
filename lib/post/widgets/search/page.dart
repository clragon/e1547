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

class _PostsPageState extends State<PostsPage> with LinkingMixin {
  Set<Post> selections = {};

  void updatePage() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (mounted) {
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
                        color: Colors.white,
                        size: min(constraint.maxHeight, constraint.maxWidth) *
                            0.4,
                      ),
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
          builder: (context, actionController) => ControlledTextWrapper(
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
      return ContextDrawer(
        title: Text('Search'),
        children: [
          SafeCrossFade(
            showChild: widget.drawerActions?.isNotEmpty ?? false,
            builder: (context) => Column(
              children: [
                ...widget.drawerActions!,
                Divider(),
              ],
            ),
          ),
          if (widget.controller.canDeny)
            DrawerDenySwitch(controller: widget.controller),
          DrawerCounter(controller: widget.controller),
        ],
      );
    }

    PreferredSizeWidget selectionAppBar() {
      return DefaultAppBar(
        title: selections.length == 1
            ? Text('post #${selections.first.id}')
            : Text('${selections.length} posts'),
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
                postDownloadingSnackbar(context, Set.from(selections));
                setState(selections.clear);
              },
            ),
          ),
          Builder(
            builder: (context) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: LikeButton(
                isLiked: selections.isNotEmpty &&
                    selections.every((post) => post.isFavorited),
                circleColor: CircleColor(start: Colors.pink, end: Colors.red),
                bubblesColor: BubblesColor(
                    dotPrimaryColor: Colors.pink,
                    dotSecondaryColor: Colors.red),
                likeBuilder: (bool isLiked) => Icon(
                  Icons.favorite,
                  color: isLiked
                      ? Colors.pinkAccent
                      : Theme.of(context).iconTheme.color,
                ),
                onTap: (isLiked) async {
                  postFavoritingSnackbar(
                      context, Set.from(selections), isLiked);
                  setState(selections.clear);
                  return !isLiked;
                },
              ),
            ),
          ),
        ],
      );
    }

    StaggeredTile? Function(int) tileBuilder(
      double tileHeightFactor,
      int crossAxisCount,
      GridState stagger,
    ) {
      return (int item) {
        if (item < widget.controller.itemList!.length) {
          PostFile image = widget.controller.itemList![item].sample;
          double widthRatio = image.width / image.height;
          double heightRatio = image.height / image.width;

          switch (stagger) {
            case GridState.square:
              return StaggeredTile.count(1, 1 * tileHeightFactor);
            case GridState.vertical:
              return StaggeredTile.count(1, heightRatio);
            case GridState.omni:
              if (crossAxisCount == 1) {
                return StaggeredTile.count(1, heightRatio);
              } else {
                return StaggeredTile.count(notZero(widthRatio),
                    notZero(heightRatio) * tileHeightFactor);
              }
          }
        }
        return null;
      };
    }

    Widget selectionScope({required Widget child}) {
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

    return TileLayoutScope(
      tileBuilder: tileBuilder,
      builder: (context, crossAxisCount, tileBuilder) => selectionScope(
        child: RefreshablePage(
          refreshController: widget.controller.refreshController,
          appBar: selections.isEmpty
              ? widget.appBarBuilder(context)
              : selectionAppBar(),
          drawer: NavigationDrawer(),
          endDrawer: endDrawer(),
          floatingActionButton: floatingActionButton(),
          refresh: () => widget.controller.refresh(background: true),
          builder: (context) => PagedStaggeredGridView(
            padding: defaultListPadding,
            key: joinKeys(['posts', tileBuilder, crossAxisCount]),
            addAutomaticKeepAlives: false,
            tileBuilder: tileBuilder,
            pagingController: widget.controller,
            crossAxisCount: crossAxisCount,
            builderDelegate: defaultPagedChildBuilderDelegate(
              pagingController: widget.controller,
              itemBuilder: itemBuilder,
              onEmpty: Text('No posts'),
              onLoading: Text('Loading posts'),
              onError: Text('Failed to load posts'),
                ),
          ),
        ),
      ),
    );
  }
}
