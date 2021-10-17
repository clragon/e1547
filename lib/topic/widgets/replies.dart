import 'package:e1547/interface/interface.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class RepliesPage extends StatefulWidget {
  final Topic topic;

  const RepliesPage({required this.topic});

  @override
  State createState() => _RepliesPageState();
}

class _RepliesPageState extends State<RepliesPage> {
  late ReplyController controller = ReplyController(topicId: widget.topic.id);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshableControllerPage(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(widget.topic.title),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            tooltip: 'Info',
            onPressed: () => topicSheet(context, widget.topic),
          ),
        ],
      ),
      controller: controller,
      builder: (context) => PagedListView(
        padding:
            EdgeInsets.only(top: 8, bottom: kBottomNavigationBarHeight + 24),
        pagingController: controller,
        builderDelegate: defaultPagedChildBuilderDelegate(
          itemBuilder: (context, Reply item, index) =>
              ReplyTile(reply: item, topic: widget.topic),
          onLoading: Text('Loading replies'),
          onEmpty: Text('No replies'),
          onError: Text('Failed to load replies'),
        ),
      ),
      drawer: NavigationDrawer(),
      endDrawer: ContextDrawer(
        title: Text('Replies'),
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: controller.orderByOldest,
            builder: (context, value, child) => SwitchListTile(
              secondary: Icon(Icons.sort),
              title: Text('Reply order'),
              subtitle: Text(value ? 'oldest first' : 'newest first'),
              value: value,
              onChanged: (value) {
                controller.orderByOldest.value = value;
                Navigator.of(context).maybePop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
