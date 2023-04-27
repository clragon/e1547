import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class TopicsPage extends StatefulWidget {
  const TopicsPage({this.search});

  final String? search;

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> with RouterDrawerEntryWidget {
  @override
  Widget build(BuildContext context) {
    return TopicsProvider(
      search: widget.search,
      child: Consumer<TopicsController>(
        builder: (context, controller, child) => SubListener(
          initialize: true,
          listenable: controller.search,
          listener: () async {
            HistoriesService service = context.read<HistoriesService>();
            Client client = context.read<Client>();
            try {
              await controller.waitForFirstPage();
              await service.addTopicSearch(
                client.host,
                controller.search.value,
                topics: controller.itemList!,
              );
            } on ClientException {
              return;
            }
          },
          child: RefreshableControllerPage(
            appBar: const DefaultAppBar(
              title: Text('Topics'),
              actions: [ContextDrawerButton()],
            ),
            floatingActionButton: SheetFloatingActionButton(
              actionIcon: Icons.search,
              builder: (context, actionController) => ControlledTextField(
                labelText: 'Topic title',
                actionController: actionController,
                textController:
                    TextEditingController(text: controller.search.value),
                submit: (value) => controller.search.value = value,
              ),
            ),
            drawer: const RouterDrawer(),
            endDrawer: ContextDrawer(
              title: const Text('Topics'),
              children: [TopicTagEditingTile(controller: controller)],
            ),
            controller: controller,
            child: PagedListView(
              primary: true,
              padding: defaultListPadding,
              pagingController: controller,
              builderDelegate: defaultPagedChildBuilderDelegate<Topic>(
                pagingController: controller,
                itemBuilder: (context, item, index) => TopicTile(
                  topic: item,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RepliesPage(topic: item),
                    ),
                  ),
                  onCountPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RepliesPage(
                        topic: item,
                        orderByOldest: false,
                      ),
                    ),
                  ),
                ),
                onEmpty: const Text('No topics'),
                onError: const Text('Failed to load topics'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
