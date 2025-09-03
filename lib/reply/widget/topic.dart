import 'package:e1547/domain/domain.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';

class TopicRepliesPage extends StatelessWidget {
  const TopicRepliesPage({super.key, required this.topic, this.orderByOldest});

  final Topic topic;
  final bool? orderByOldest;

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    return FilterControllerProvider(
      create: (_) => ReplyFilter(domain),
      keys: (_) => [domain],
      child: ListenableProvider(
        create: (_) => ReplyParams()
          ..topicId = topic.id
          ..order = (orderByOldest ?? true)
              ? ReplyOrder.oldest
              : ReplyOrder.newest,
        builder: (context, _) => AdaptiveScaffold(
          appBar: DefaultAppBar(
            title: Text(topic.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline),
                tooltip: 'Info',
                onPressed: () =>
                    showTopicPrompt(context: context, topic: topic),
              ),
              const ContextDrawerButton(),
            ],
          ),
          drawer: const RouterDrawer(),
          endDrawer: const ReplyListDrawer(),
          body: const ReplyList(),
        ),
      ),
    );
  }
}
