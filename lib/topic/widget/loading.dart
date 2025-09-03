import 'package:e1547/domain/domain.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class TopicLoadingPage extends StatefulWidget {
  const TopicLoadingPage(this.id, {super.key, this.orderByOldest});

  final int id;
  final bool? orderByOldest;

  @override
  State<TopicLoadingPage> createState() => _TopicLoadingPageState();
}

class _TopicLoadingPageState extends State<TopicLoadingPage> {
  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    final query = domain.topics.useGet(id: widget.id);

    return QueryBuilder(
      query: query,
      builder: (context, state) {
        if (state.data != null) {
          return TopicRepliesPage(
            topic: state.data!,
            orderByOldest: widget.orderByOldest,
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text('Topic #${widget.id}')),
          body: Center(
            child: state.isLoading
                ? const CircularProgressIndicator()
                : state.error != null
                ? const Text('Failed to load topic')
                : const Text('Topic not found'),
          ),
        );
      },
    );
  }
}
