import 'package:e1547/client.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/post.dart';
import 'package:e1547/tag.dart';
import 'package:flutter/material.dart';

class PoolPage extends StatefulWidget {
  final Pool pool;

  PoolPage({required this.pool});

  @override
  _PoolPageState createState() => _PoolPageState();
}

class _PoolPageState extends State<PoolPage> {
  late PostController controller;

  @override
  void initState() {
    super.initState();
    controller = PostController(
      provider: (tags, page) => client.poolPosts(widget.pool.id, page),
      canSearch: false,
    );
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
      appBarBuilder: (context) {
        return AppBar(
          title: Text(tagToTitle(widget.pool.name)),
          leading: BackButton(),
          actions: [
            IconButton(
              icon: Icon(Icons.info_outline),
              tooltip: 'Info',
              onPressed: () => poolSheet(context, widget.pool),
            )
          ],
        );
      },
    );
  }
}
