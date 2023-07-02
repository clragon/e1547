import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouterDrawerEntryWidget {
  @override
  Widget build(BuildContext context) {
    return PostsProvider(
      search: context.read<Settings>().homeTags.value,
      child: Consumer<PostsController>(
        builder: (context, controller, child) =>
            PostsControllerHistoryConnector(
          controller: controller,
          child: SubListener(
            initialize: true,
            listenable: controller,
            listener: () =>
                context.read<Settings>().homeTags.value = controller.search,
            builder: (context) => PostsPage(
              appBar: const ContextSizedAppBar(
                title: Text('Home'),
              ),
              controller: controller,
            ),
          ),
        ),
      ),
    );
  }
}
