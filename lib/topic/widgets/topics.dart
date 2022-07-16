import 'package:e1547/interface/interface.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

class TopicsPage extends StatefulWidget {
  final String? search;

  const TopicsPage({this.search});

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> with DrawerEntry {
  @override
  Widget build(BuildContext context) {
    return TopicsProvider(
      search: widget.search,
      child: Consumer<TopicsController>(
        builder: (context, controller, child) => RefreshableControllerPage(
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
          builder: (context) => PagedListView(
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
    );
  }
}
