import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';

class TopicLoadingPage extends StatefulWidget {
  const TopicLoadingPage(this.id, {super.key, this.orderByOldest});

  final int id;
  final bool? orderByOldest;

  @override
  State<TopicLoadingPage> createState() => _TopicLoadingPageState();
}

class _TopicLoadingPageState extends State<TopicLoadingPage> {
  late Future<Topic> topic = context.read<Client>().topics.topic(id: widget.id);

  @override
  Widget build(BuildContext context) {
    return FutureLoadingPage<Topic>(
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
