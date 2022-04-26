import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';

class TopicLoadingPage extends StatefulWidget {
  final int id;
  final bool orderByOldest;

  const TopicLoadingPage(this.id, {this.orderByOldest = true});

  @override
  _TopicLoadingPageState createState() => _TopicLoadingPageState();
}

class _TopicLoadingPageState extends State<TopicLoadingPage> {
  late Future<Topic> topic = client.topic(widget.id);

  @override
  Widget build(BuildContext context) {
    return FuturePageLoader<Topic>(
      future: topic,
      builder: (context, value) => RepliesPage(
        topic: value,
        orderByOldest: widget.orderByOldest,
      ),
      title: Text('Topic #${widget.id}'),
      onError: const Text('Failed to load topic'),
      onEmpty: const Text('Topic not found'),
    );
  }
}

class ReplyLoadingPage extends StatefulWidget {
  final int id;

  const ReplyLoadingPage(this.id);

  @override
  _ReplyLoadingPageState createState() => _ReplyLoadingPageState();
}

class _ReplyLoadingPageState extends State<ReplyLoadingPage> {
  late Future<Reply> reply = client.reply(widget.id);

  @override
  Widget build(BuildContext context) {
    return FuturePageLoader<Reply>(
      future: reply,
      builder: (context, value) => TopicLoadingPage(value.topicId),
      title: Text('Reply #${widget.id}'),
      onError: const Text('Failed to load reply'),
      onEmpty: const Text('Reply not found'),
    );
  }
}
