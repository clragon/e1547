import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/material.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({
    super.key,
    required this.controller,
    required this.appBar,
    this.displayType,
    this.drawerActions,
    this.canSelect = true,
  });

  final PostController controller;
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
        return PostsPageFloatingActionButton(controller: widget.controller);
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
            builder:
                (context) => Column(
                  children: [...widget.drawerActions!, const Divider()],
                ),
          ),
          if (widget.controller.filterMode != PostFilterMode.unavailable)
            DrawerDenySwitch(controller: widget.controller),
          DrawerTagCounter(controller: widget.controller),
        ],
      );
    }

    return ChangeNotifierProvider.value(
      value: widget.controller,
      child: Consumer<PostController>(
        builder:
            (context, controller, child) => SelectionLayout<Post>(
              enabled: widget.canSelect,
              items: controller.items,
              child: RefreshableDataPage.builder(
                appBar: PostSelectionAppBar(
                  controller: widget.controller,
                  child: widget.appBar,
                ),
                drawer: const RouterDrawer(),
                endDrawer: endDrawer(),
                floatingActionButton: floatingActionButton(),
                builder:
                    (context, child) =>
                        LimitedWidthLayout(child: TileLayout(child: child)),
                controller: widget.controller,
                child:
                    (context) => CustomScrollView(
                      primary: true,
                      slivers: [
                        SliverPadding(
                          padding: defaultActionListPadding,
                          sliver: PostSliverDisplay(
                            controller: widget.controller,
                            displayType:
                                widget.displayType ?? PostDisplayType.grid,
                          ),
                        ),
                      ],
                    ),
              ),
            ),
      ),
    );
  }
}
