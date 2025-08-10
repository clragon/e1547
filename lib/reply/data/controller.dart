import 'package:e1547/client/client.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class ReplyController extends PageClientDataController<Reply> {
  ReplyController({
    required this.client,
    required this.topicId,
    bool? orderByOldest,
  }) : _orderByOldest = orderByOldest ?? true {
    client.traits.addListener(applyFilter);
  }

  @override
  final Client client;
  final int topicId;

  bool _orderByOldest;
  bool get orderByOldest => _orderByOldest;
  set orderByOldest(bool value) {
    if (_orderByOldest == value) return;
    _orderByOldest = value;
    refresh();
  }

  @override
  @protected
  Future<List<Reply>> fetch(int page, bool force) => client.replies.byTopic(
    id: topicId,
    page: page,
    ascending: orderByOldest,
    force: force,
    cancelToken: cancelToken,
  );

  @override
  void dispose() {
    client.traits.removeListener(applyFilter);
    super.dispose();
  }
}

class ReplyProvider extends SubChangeNotifierProvider<Client, ReplyController> {
  ReplyProvider({
    required int topicId,
    bool? orderByOldest,
    super.child,
    super.builder,
  }) : super(
         create: (context, client) => ReplyController(
           client: client,
           topicId: topicId,
           orderByOldest: orderByOldest,
         ),
         keys: (context) => [topicId, orderByOldest],
       );
}
