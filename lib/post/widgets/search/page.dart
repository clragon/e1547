import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
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

class _PostsPageState extends State<PostsPage> with ListenerCallbackMixin {
  Set<Post> selections = {};

  @override
  Map<ChangeNotifier, VoidCallback> get listeners => {
        widget.controller: updatePage,
      };

  void updatePage() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          selections.removeWhere((element) =>
              !(widget.controller.itemList?.contains(element) ?? true));
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
        title: Text('Posts'),
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
      return PostTile(
        post: item,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PostDetailGallery(
              controller: widget.controller,
              initialPage: index,
            ),
          ));
        },
      );
    }

    TileLayoutTileBuilder tileBuilder = defaultStaggerTileBuilder(
      (index) {
        PostFile image = widget.controller.itemList![index].sample;
        return Size(image.width.toDouble(), image.height.toDouble());
      },
    );

    return TileLayoutScope(
      tileBuilder: tileBuilder,
      builder: (context, crossAxisCount, tileBuilder) => SelectionScope<Post>(
        selections: selections,
        builder: (context, selections, onChanged) => RefreshablePage(
          refreshController: widget.controller.refreshController,
          appBar: selections.isEmpty
              ? widget.appBarBuilder(context)
              : PostSelectionAppBar(
                  selections: selections,
                  onChanged: onChanged,
                  onSelectAll: () => widget.controller.itemList!.toSet()),
          drawer: defaultNavigationDrawer(),
          endDrawer: endDrawer(),
          floatingActionButton: floatingActionButton(),
          refresh: () =>
              widget.controller.refresh(background: true, force: true),
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
              itemBuilder: (context, Post item, index) => SelectionItemOverlay(
                enabled: widget.canSelect,
                padding: EdgeInsets.all(4),
                child: itemBuilder(context, item, index),
                item: item,
                selections: selections,
                onChanged: onChanged,
              ),
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
