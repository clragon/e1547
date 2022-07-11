import 'dart:math';

import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

enum HistoryFilter {
  posts,
  pools,
  searches,
}

class HistoriesController extends DataController<History> {
  @override
  Future<List<History>> provide(int page, bool force) {
    // TODO: implement provide
    throw UnimplementedError();
  }
}
