import 'dart:math';

import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/thread.dart';
import 'package:meta/meta.dart';

class ReplyProvider extends DataProvider<Reply> {
  final Thread thread;

  ReplyProvider({@required this.thread});

  @override
  Future<List<Reply>> provide(int page) async {
    String cursor;
    pages.value.isEmpty
        ? cursor = 'a0'
        : cursor =
            'a${pages.value.last.map((e) => e.id).reduce(max).toString()}';
    List<Reply> replies = await client.replies(thread, cursor);
    replies.sort((one, two) =>
        DateTime.parse(one.creation).compareTo(DateTime.parse(two.creation)));
    replies.removeWhere((element) => element.topicId != thread.id);
    return replies;
  }
}
