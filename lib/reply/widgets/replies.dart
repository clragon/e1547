import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

class RepliesPage extends StatelessWidget {
  final Topic topic;
  final bool orderByOldest;

  const RepliesPage({required this.topic, this.orderByOldest = true});

  @override
  Widget build(BuildContext context) {
    return RepliesProvider(
      topicId: topic.id,
      orderByOldest: orderByOldest,
      child: Consumer<RepliesController>(
        builder: (context, controller, child) => ListenableListener(
          listener: () async {
            await controller.waitForFirstPage();
            context.read<HistoriesService>().addTopic(
                  topic,
                  // TODO: figure out how this can be null
                  replies: controller.itemList ?? [],
                );
          },
          listenable: controller.orderByOldest,
          child: RefreshableControllerPage(
            appBar: DefaultAppBar(
              leading: const BackButton(),
              title: Text(topic.title),
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Info',
                  onPressed: () => topicSheet(context, topic),
                ),
                const ContextDrawerButton(),
              ],
            ),
            controller: controller,
            builder: (context) => PagedListView(
              padding: defaultActionListPadding,
              pagingController: controller,
              builderDelegate: defaultPagedChildBuilderDelegate<Reply>(
                pagingController: controller,
                itemBuilder: (context, item, index) =>
                    ReplyTile(reply: item, topic: topic),
                onEmpty: const Text('No replies'),
                onError: const Text('Failed to load replies'),
              ),
            ),
            drawer: const NavigationDrawer(),
            endDrawer: ContextDrawer(
              title: const Text('Replies'),
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: controller.orderByOldest,
                  builder: (context, value, child) => SwitchListTile(
                    secondary: const Icon(Icons.sort),
                    title: const Text('Reply order'),
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
          ),
        ),
      ),
    );
  }
}
