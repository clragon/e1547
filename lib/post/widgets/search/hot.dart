import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HotPage extends StatefulWidget {
  const HotPage();

  @override
  State<HotPage> createState() => _HotPageState();
}

class _HotPageState extends State<HotPage> with DrawerEntry {
  @override
  Widget build(BuildContext context) {
    return PostsProvider(
      search: 'order:rank',
      child: Consumer<PostsController>(
        builder: (context, controller, child) => ListenableListener(
          listener: () async {
            await controller.waitForFirstPage();
            await context.read<HistoriesService>().addPostSearch(
                controller.search.value,
                posts: controller.itemList);
          },
          listenable: controller.search,
          child: PostsPage(
            appBar: const ContextSizedAppBar(
              title: Text('Hot'),
            ),
            controller: controller,
          ),
        ),
      ),
    );
  }
}
