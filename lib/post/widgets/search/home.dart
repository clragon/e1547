import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          listener: () {
            context.read<Settings>().homeTags.value = controller.search.value;
            // TODO: reenable
            // controller.addToHistory(context);
          },
          listenable: controller,
          child: PostsPage(
            appBar: const DefaultAppBar(
              title: Text('Home'),
              actions: [SizedBox.shrink()],
            ),
            controller: controller,
          ),
        ),
      ),
    );
  }
}
