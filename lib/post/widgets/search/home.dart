import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with DrawerEntry {
  @override
  Widget build(BuildContext context) {
    return PostsProvider(
      search: context.read<Settings>().homeTags.value,
      child: Consumer<PostsController>(
        builder: (context, controller, child) => ListenableListener(
          listener: () async {
            context.read<Settings>().homeTags.value = controller.search.value;
            await controller.waitForFirstPage();
            context.read<HistoriesService>().addPostSearch(
                controller.search.value,
                posts: controller.itemList);
          },
          listenable: controller.search,
          child: PostsPage(
            appBar: const ContextSizedAppBar(
              title: Text('Home'),
            ),
            controller: controller,
          ),
        ),
      ),
    );
  }
}
