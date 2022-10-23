import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class TopicsPage extends StatefulWidget {
  const TopicsPage({this.search});

  final String? search;

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> with DrawerEntry {
  @override
  Widget build(BuildContext context) {
    return TopicsProvider(
      search: widget.search,
      child: Consumer<TopicsController>(
        builder: (context, controller, child) => ListenableListener(
          listener: () async {
            await controller.waitForFirstPage();
            await context.read<HistoriesService>().addTopicSearch(
              context.read<Client>().host,
                  controller.search.value,
                  topics: controller.itemList!,
                );
          },
          listenable: controller.search,
          child: RefreshableControllerPage(
            appBar: const DefaultAppBar(title: Text('Topics')),
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
            drawer: const NavigationDrawer(),
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
