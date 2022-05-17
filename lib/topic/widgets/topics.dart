import 'package:e1547/interface/interface.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class TopicsPage extends StatefulWidget {
  final String? search;

  const TopicsPage({this.search});

  @override
  State<StatefulWidget> createState() {
    return _TopicsPageState();
  }
}

class _TopicsPageState extends State<TopicsPage> {
  late TopicController controller = TopicController(search: widget.search);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshableControllerPage(
      appBar: const DefaultAppBar(title: Text('Topics')),
      floatingActionButton: SheetFloatingActionButton(
        actionIcon: Icons.search,
        builder: (context, actionController) => ControlledTextField(
          labelText: 'Topic title',
          actionController: actionController,
          textController: TextEditingController(text: controller.search.value),
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
    );
  }
}
