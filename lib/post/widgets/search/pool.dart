import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class PoolPage extends StatefulWidget {
  final Pool pool;

  const PoolPage({required this.pool});

  @override
  _PoolPageState createState() => _PoolPageState();
}

class _PoolPageState extends State<PoolPage> {
  late PostController controller;
  bool reversePool = false;

  Future<void> addToHistory() async {
    await controller.waitForFirstPage();
    historyController.addTag(
      widget.pool.search,
      alias: widget.pool.name,
      posts: controller.itemList,
    );
  }

  @override
  void initState() {
    super.initState();
    controller = PostController(
      provider: (tags, page, force) => client.poolPosts(widget.pool.id, page,
          reverse: reversePool, force: force),
      canSearch: false,
    );
    addToHistory();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PostsPage(
      controller: controller,
      appBarBuilder: (context) => DefaultAppBar(
        title: Text(tagToTitle(widget.pool.name)),
        leading: BackButton(),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            tooltip: 'Info',
            onPressed: () => poolSheet(context, widget.pool),
          ),
          ContextDrawerButton(),
        ],
      ),
      drawerActions: [
        PoolOrderSwitch(
          reversePool: reversePool,
          onChange: (value) {
            setState(() {
              reversePool = value;
            });
            controller.refresh();
            Navigator.of(context).maybePop();
          },
        ),
      ],
    );
  }
}

class PoolOrderSwitch extends StatelessWidget {
  final bool reversePool;
  final void Function(bool value) onChange;
  const PoolOrderSwitch({required this.reversePool, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(Icons.sort),
      title: Text('Pool order'),
      subtitle: Text(reversePool ? 'newest first' : 'oldest first'),
      value: reversePool,
      onChanged: onChange,
    );
  }
}
