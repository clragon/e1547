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
              textInputAction: TextInputAction.search,
              labelText: 'Tags',
              controller: controller,
              submit: submit,
            ),
          ),
        );
      } else {
        return null;
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
          if (widget.controller.denyMode != DenyListMode.unavailable)
            DrawerDenySwitch(controller: widget.controller),
          DrawerCounter(controller: widget.controller),
          ListTile(
            onTap: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('posts: ${widget.controller.itemList!.length}'),
                content: SizedBox(
                  height: 500,
                  width: 200,
                  child: ListView.builder(
                    itemCount: widget.controller.itemList!.length,
                    itemBuilder: (context, index) {
                      Post current = widget.controller.itemList![index];
                      return Text(
                        current.id.toString(),
                        style: TextStyle(
                          color: widget.controller.itemList!
                                  .sublist(0, index)
                                  .any((element) => element.id == current.id)
                              ? Colors.red
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            title: Text('post ids'),
          ),
        ],
      );
    }

    Widget itemBuilder(BuildContext context, Post item, int index) {
      return PostTile(
        post: item,
        controller: widget.controller,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PostDetailGallery(
                controller: widget.controller,
                initialPage: index,
              ),
            ),
          );
        },
      );
    }

    return TileLayout(
      child: SelectionScope<Post>(
        selections: selections,
        builder: (context, selections, onChanged) => RefreshablePage(
          refreshController: widget.controller.refreshController,
          appBar: selections.isEmpty
              ? widget.appBarBuilder(context)
              : PostSelectionAppBar(
                  selections: selections,
                  onChanged: onChanged,
                  controller: widget.controller,
                  onSelectAll: () => widget.controller.itemList!.toSet(),
                ),
          drawer: defaultNavigationDrawer(),
          endDrawer: endDrawer(),
          floatingActionButton: floatingActionButton(),
          refresh: () => widget.controller.backgroundRefresh(force: true),
          builder: (context) => PagedStaggeredGridView(
            key: joinKeys(['posts', TileLayout.of(context).crossAxisCount]),
            physics: BouncingScrollPhysics(),
            showNewPageErrorIndicatorAsGridChild: false,
            showNewPageProgressIndicatorAsGridChild: false,
            showNoMoreItemsIndicatorAsGridChild: false,
            padding: defaultListPadding,
            addAutomaticKeepAlives: false,
            pagingController: widget.controller,
            builderDelegate: defaultPagedChildBuilderDelegate<Post>(
              pagingController: widget.controller,
              itemBuilder: (context, item, index) => SelectionItemOverlay(
                enabled: widget.canSelect,
                padding: EdgeInsets.all(4),
                child: itemBuilder(context, item, index),
                item: item,
                selections: selections,
                onChanged: onChanged,
              ),
              onEmpty: Text('No posts'),
              onError: Text('Failed to load posts'),
            ),
            gridDelegateBuilder: (childCount) =>
                SliverStaggeredGridDelegateWithFixedCrossAxisCount(
              staggeredTileBuilder: postStaggeredTileBuilder(
                  context, (index) => widget.controller.itemList![index]),
              crossAxisCount: TileLayout.of(context).crossAxisCount,
              staggeredTileCount: widget.controller.itemList?.length,
            ),
          ),
        ),
      ),
    );
  }
}
