import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';

class TopicsPage extends StatelessWidget {
  const TopicsPage({this.search});

  final QueryMap? search;

  @override
  Widget build(BuildContext context) {
    return RouterDrawerEntry<TopicsPage>(
      child: TopicsProvider(
        search: search,
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
              floatingActionButton: TopicsPageFloatingActionButton(
                controller: controller,
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
      ),
    );
  }
}
