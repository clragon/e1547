import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouterDrawerEntryWidget {
  @override
  Widget build(BuildContext context) {
    Client client = context.watch<Client>();
    return PostProvider(
      query: {'tags': client.traits.value.homeTags},
      child: Consumer<PostController>(
        builder: (context, controller, child) =>
            PostsControllerHistoryConnector(
              controller: controller,
              child: SubListener(
                initialize: true,
                listenable: controller,
                listener: () => client.accounts.push(
                  traits: client.traits.value.copyWith(
                    homeTags: controller.query['tags'].toString(),
                  ),
                ),
                builder: (context) => PostsPage(
                  appBar: const DefaultAppBar(
                    title: Center(child: AppIcon()),
                    actions: [ContextDrawerButton()],
                  ),
                  controller: controller,
                ),
              ),
            ),
      ),
    );
  }
}
