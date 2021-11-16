import 'package:e1547/interface/interface.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class TopicsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TopicsPageState();
  }
}

class _TopicsPageState extends State<TopicsPage> {
  TopicController controller = TopicController();

  @override
  Widget build(BuildContext context) {
    return RefreshableControllerPage(
      appBar: DefaultAppBar(title: Text('Topics')),
      floatingActionButton: SheetFloatingActionButton(
        actionIcon: Icons.search,
        builder: (context, actionController) => ControlledTextField(
          labelText: 'Topic title',
          actionController: actionController,
          textController: TextEditingController(text: controller.search.value),
          submit: (value) => controller.search.value = value,
        ),
      ),
      drawer: NavigationDrawer(),
      controller: controller,
      builder: (context) => PagedListView(
        padding: defaultListPadding,
        pagingController: controller,
        builderDelegate: defaultPagedChildBuilderDelegate(
          pagingController: controller,
          itemBuilder: (context, Topic item, index) => TopicTile(
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
          onLoading: Text('Loading topics'),
          onEmpty: Text('No topics'),
          onError: Text('Failed to load topics'),
        ),
      ),
    );
  }
}
