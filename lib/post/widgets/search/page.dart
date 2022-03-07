import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/main.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        title: Text('Posts'),
        children: [
          CrossFade.builder(
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
          // TODO: fix duplicates and remove this
          if (settings.showBeta.value) ...[
            Divider(),
            ListTile(
              leading: Icon(Icons.format_list_numbered),
              title: Text('LOG'),
              onTap: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    '${widget.controller.itemList!.length} items / ${widget.controller.itemList!.asMap().entries.where((e) => widget.controller.itemList!.sublist(
                          0,
                          e.key,
                        ).any((element) => element.id == widget.controller.itemList![e.key].id)).length} duplicates!',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        log.clear();
                        Navigator.of(context).maybePop();
                      },
                      child: Text('CLEAR'),
                    ),
                    TextButton(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: log.join('\n'),
                          ),
                        );
                      },
                      child: Text('COPY'),
                    ),
                    TextButton(
                      onPressed: Navigator.of(context).maybePop,
                      child: Text('OK'),
                    ),
                  ],
                  content: SingleChildScrollView(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            log.join('\n'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]
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
            appbar: widget.appBarBuilder(context),
            controller: widget.controller,
          ),
          drawer: NavigationDrawer(),
          endDrawer: endDrawer(),
          floatingActionButton: floatingActionButton(),
          refresh: () => widget.controller.backgroundRefresh(force: true),
          builder: (context) => postGrid(context, widget.controller),
        ),
      ),
    );
  }
}
