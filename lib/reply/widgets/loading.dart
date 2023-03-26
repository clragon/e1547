import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';

class ReplyLoadingPage extends StatefulWidget {
  const ReplyLoadingPage(this.id, {this.orderByOldest});

  final int id;
  final bool? orderByOldest;

  @override
  State<ReplyLoadingPage> createState() => _ReplyLoadingPageState();
}

class _ReplyLoadingPageState extends State<ReplyLoadingPage> {
  late Future<Reply> reply = context.read<Client>().reply(widget.id);

  @override
  Widget build(BuildContext context) {
    return FutureLoadingPage<Reply>(
      future: reply,
      builder: (context, value) => TopicLoadingPage(
        value.topicId,
        orderByOldest: widget.orderByOldest,
      ),
      title: Text('Reply #${widget.id}'),
      onError: const Text('Failed to load reply'),
      onEmpty: const Text('Reply not found'),
    );
  }
}
