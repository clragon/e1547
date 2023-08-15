import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';

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
        builder: (context, controller, child) => ControllerHistoryConnector(
          controller: controller,
          addToHistory: (context, service, data) => service.addTopicSearch(
            controller.client.host,
            controller.search,
            topics: controller.items!,
          ),
          child: RefreshableDataPage(
            appBar: const DefaultAppBar(
              title: Text('Topics'),
              actions: [ContextDrawerButton()],
            ),
            floatingActionButton: SheetFloatingActionButton(
              actionIcon: Icons.search,
              builder: (context, actionController) => ControlledTextField(
                labelText: 'Topic title',
                actionController: actionController,
                textController: TextEditingController(text: controller.search),
                submit: (value) => controller.search = value,
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
              pagingController: controller.paging,
              builderDelegate: defaultPagedChildBuilderDelegate<Topic>(
                pagingController: controller.paging,
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
