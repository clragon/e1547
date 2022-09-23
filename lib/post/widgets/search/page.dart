import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class PostsPage extends StatefulWidget {
  PostsPage({
    required this.controller,
    required this.appBar,
    this.displayType,
    this.drawerActions,
    this.canSelect = true,
  }) : super(key: ObjectKey(controller));

  final PostsController controller;
  final PreferredSizeWidget appBar;
  final List<Widget>? drawerActions;
  final PostDisplayType? displayType;
  final bool canSelect;

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
          DrawerTagCounter(controller: widget.controller),
        ],
      );
    }

    return ChangeNotifierProvider.value(
      value: widget.controller,
      child: Consumer<PostsController>(
        builder: (context, controller, child) => SelectionLayout<Post>(
          enabled: widget.canSelect,
          items: controller.itemList,
          child: RefreshableControllerPage.builder(
            appBar: PostSelectionAppBar(
              controller: widget.controller,
              child: widget.appBar,
            ),
            drawer: const NavigationDrawer(),
            endDrawer: endDrawer(),
            floatingActionButton: floatingActionButton(),
            builder: (context, child) =>
                LimitedWidthLayout(child: TileLayout(child: child)),
            controller: widget.controller,
            child: (context) => postDisplay(
              context: context,
              controller: widget.controller,
              displayType: widget.displayType ?? PostDisplayType.grid,
            ),
          ),
        ),
      ),
    );
  }
}
