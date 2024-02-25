import 'package:e1547/client/client.dart';
import 'package:e1547/reply/reply.dart';
import 'package:flutter/material.dart';

class RepliesController extends PageClientDataController<Reply> {
  RepliesController({
    required this.client,
    required this.topicId,
    bool? orderByOldest,
  }) : _orderByOldest = orderByOldest ?? true {
    client.traitsState.addListener(applyFilter);
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
    client.traitsState.removeListener(applyFilter);
    super.dispose();
  }
}

class RepliesProvider
    extends SubChangeNotifierProvider<Client, RepliesController> {
  RepliesProvider({
    required int topicId,
    bool? orderByOldest,
    super.child,
    super.builder,
  }) : super(
          create: (context, client) => RepliesController(
            client: client,
            topicId: topicId,
            orderByOldest: orderByOldest,
          ),
          keys: (context) => [topicId, orderByOldest],
        );
}
