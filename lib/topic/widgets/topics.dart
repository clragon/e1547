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
      appBar: AppBar(title: Text('Topics')),
      drawer: NavigationDrawer(),
      controller: controller,
      builder: (context) {
        return PagedListView(
          pagingController: controller,
          builderDelegate: defaultPagedChildBuilderDelegate(
            itemBuilder: (context, Topic item, index) => TopicTile(
              topic: item,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RepliesPage(topic: item),
                ),
              ),
            ),
            onLoading: Text('Loading threads'),
            onEmpty: Text('No threads'),
            onError: Text('Failed to load threads'),
          ),
        );
      },
    );
  }
}
