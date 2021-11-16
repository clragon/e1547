import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

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

  @override
  Map<ChangeNotifier, VoidCallback> get links => {
        widget.controller: updatePage,
      };

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

    Widget itemBuilder(BuildContext context, Post item, int index) {
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
              child: PostSelectionOverlay(
            post: item,
            selections: selections,
            select: (Post post) {
              if (widget.canSelect) {
                setState(() {
                  if (selections.contains(item)) {
                    selections.remove(item);
                  } else {
                    selections.add(item);
                  }
                });
              }
            },
          )),
        ],
      );
    }

    StaggeredTile? Function(int) tileBuilder(
      double tileHeightFactor,
      int crossAxisCount,
      GridQuilt stagger,
    ) {
      return (int item) {
        if (item < widget.controller.itemList!.length) {
          PostFile image = widget.controller.itemList![item].sample;
          double widthRatio = image.width / image.height;
          double heightRatio = image.height / image.width;

          switch (stagger) {
            case GridQuilt.square:
              return StaggeredTile.count(1, 1 * tileHeightFactor);
            case GridQuilt.vertical:
              return StaggeredTile.count(1, heightRatio);
            case GridQuilt.omni:
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

    return TileLayoutScope(
      tileBuilder: tileBuilder,
      builder: (context, crossAxisCount, tileBuilder) => SelectionScope<Post>(
        selections: selections,
        onChanged: (value) => setState(() => selections = value),
        child: RefreshablePage(
          refreshController: widget.controller.refreshController,
          appBar: selections.isEmpty
              ? widget.appBarBuilder(context)
              : PostSelectionAppBar(
                  selections: selections,
                  onChanged: (value) => setState(() => selections = value),
                  onSelectAll: () => widget.controller.itemList!.toSet()),
          drawer: NavigationDrawer(),
          endDrawer: endDrawer(),
          floatingActionButton: floatingActionButton(),
          refresh: () => widget.controller.refresh(background: true),
          builder: (context) => PagedStaggeredGridView(
            key: joinKeys(['posts', crossAxisCount]),
            showNewPageErrorIndicatorAsGridChild: false,
            showNewPageProgressIndicatorAsGridChild: false,
            showNoMoreItemsIndicatorAsGridChild: false,
            padding: defaultListPadding,
            addAutomaticKeepAlives: false,
            pagingController: widget.controller,
            builderDelegate: defaultPagedChildBuilderDelegate(
              pagingController: widget.controller,
              itemBuilder: itemBuilder,
              onEmpty: Text('No posts'),
              onLoading: Text('Loading posts'),
              onError: Text('Failed to load posts'),
            ),
            gridDelegateBuilder: (childCount) =>
                SliverStaggeredGridDelegateWithFixedCrossAxisCount(
              staggeredTileBuilder: tileBuilder,
              crossAxisCount: crossAxisCount,
              staggeredTileCount: widget.controller.itemList?.length,
            ),
          ),
        ),
      ),
    );
  }
}
