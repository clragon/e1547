import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';

class RepliesPage extends StatelessWidget {
  const RepliesPage({required this.topic, this.orderByOldest = true});

  final Topic topic;
  final bool orderByOldest;

  @override
  Widget build(BuildContext context) {
    return RepliesProvider(
      topicId: topic.id,
      orderByOldest: orderByOldest,
      child: Consumer<RepliesController>(
        builder: (context, controller, child) => ListenableListener(
          initialize: true,
          listenable: controller.orderByOldest,
          listener: () async {
            HistoriesService service = context.read<HistoriesService>();
            Client client = context.read<Client>();
            await controller.waitForFirstPage();
            await service.addTopic(
              client.host,
              topic,
              replies: controller.itemList!,
            );
          },
          child: RefreshableControllerPage(
            appBar: DefaultAppBar(
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
            child: PagedListView(
              primary: true,
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
          ),
        ),
      ),
    );
  }
}
