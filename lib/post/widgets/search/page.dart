import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class PostsPage extends StatefulWidget {
  final bool canSelect;
  final PostController controller;
  final PreferredSizeWidget appBar;
  final List<Widget>? drawerActions;

  PostsPage({
    this.canSelect = true,
    required this.controller,
    required this.appBar,
    this.drawerActions,
  }) : super(key: ObjectKey(controller));

  @override
  State<StatefulWidget> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
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
        title: const Text('Posts'),
        children: [
          CrossFade.builder(
            showChild: widget.drawerActions?.isNotEmpty ?? false,
            builder: (context) => Column(
              children: [
                ...widget.drawerActions!,
                const Divider(),
              ],
            ),
          ),
          if (widget.controller.denyMode != DenyListMode.unavailable)
            DrawerDenySwitch(controller: widget.controller),
          DrawerCounter(controller: widget.controller),
        ],
      );
    }

    return TileLayout(
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) => SelectionLayout<Post>(
          enabled: widget.canSelect,
          items: widget.controller.itemList,
          child: child!,
        ),
        child: RefreshablePage(
          refreshController: widget.controller.refreshController,
          appBar: PostSelectionAppBar(
            child: widget.appBar,
            controller: widget.controller,
          ),
          drawer: const NavigationDrawer(),
          endDrawer: endDrawer(),
          floatingActionButton: floatingActionButton(),
          refresh: () =>
              widget.controller.refresh(background: true, force: true),
          builder: (context) => postGrid(context, widget.controller),
        ),
      ),
    );
  }
}
