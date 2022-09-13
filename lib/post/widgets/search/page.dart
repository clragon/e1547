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
  late PostDisplayType displayType = widget.displayType ?? PostDisplayType.grid;

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
          ListTile(
            leading: const Icon(Icons.grid_view_sharp),
            title: const Text('Toggle display type (experimental)'),
            subtitle: Text(displayType.name),
            onTap: () {
              switch (displayType) {
                case PostDisplayType.grid:
                  setState(() {
                    displayType = PostDisplayType.comic;
                  });
                  break;
                case PostDisplayType.comic:
                  setState(() {
                    displayType = PostDisplayType.timeline;
                  });
                  break;
                case PostDisplayType.timeline:
                  setState(() {
                    displayType = PostDisplayType.grid;
                  });
                  break;
              }
            },
          ),
          const Divider(),
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
              displayType: displayType,
            ),
          ),
        ),
      ),
    );
  }
}
