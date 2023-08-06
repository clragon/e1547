import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/reply/reply.dart';
import 'package:flutter/material.dart';

class RepliesController extends CursorClientDataController<Reply> {
  RepliesController({
    required this.client,
    required this.topicId,
    required this.denylist,
    super.orderByOldest,
  }) {
    denylist.addListener(applyFilter);
  }

  @override
  final Client client;
  final int topicId;
  final DenylistService denylist;

  @override
  @protected
  Future<List<Reply>> fetch(String page, bool force) => client.replies(
        topicId,
        page,
        force: force,
        cancelToken: cancelToken,
      );

  @override
  @protected
  int getId(Reply item) => item.id;

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
