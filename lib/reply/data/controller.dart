import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/reply/reply.dart';
import 'package:flutter/material.dart';

class RepliesController extends PageClientDataController<Reply> {
  RepliesController({
    required this.client,
    required this.topicId,
    required this.denylist,
    bool? orderByOldest,
  }) : _orderByOldest = orderByOldest ?? true {
    denylist.addListener(applyFilter);
  }

  @override
  final Client client;
  final int topicId;
  final DenylistService denylist;

  bool _orderByOldest;
  bool get orderByOldest => _orderByOldest;
  set orderByOldest(bool value) {
    if (_orderByOldest == value) return;
    _orderByOldest = value;
    refresh();
  }

  @override
  @protected
  Future<List<Reply>> fetch(int page, bool force) => client.replies(
        id: topicId,
        page: page,
        ascending: orderByOldest,
        force: force,
        cancelToken: cancelToken,
      );

  @override
  void dispose() {
    denylist.removeListener(applyFilter);
    super.dispose();
  }
}

class RepliesProvider extends SubChangeNotifierProvider2<Client,
    DenylistService, RepliesController> {
  RepliesProvider({
    required int topicId,
    bool? orderByOldest,
    super.child,
    super.builder,
  }) : super(
          create: (context, client, denylist) => RepliesController(
            client: client,
            topicId: topicId,
            denylist: denylist,
            orderByOldest: orderByOldest,
          ),
          keys: (context) => [topicId, orderByOldest],
        );
}
