import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

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
          initialize: true,
          listenable: controller.search,
          listener: () async {
            HistoriesService service = context.read<HistoriesService>();
            Client client = context.read<Client>();
            await controller.waitForFirstPage();
            await service.addPostSearch(
              client.host,
              controller.search.value,
              posts: controller.itemList,
            );
          },
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
