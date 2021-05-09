import 'dart:math';

import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:meta/meta.dart';

import 'comment.dart';

class CommentProvider extends DataProvider<Comment> {
  final int postID;
  List<Comment> get comments => super.items;

  CommentProvider({@required this.postID});

  @override
  Future<List<Comment>> provide(int page) async {
    String cursor;
    pages.value.isEmpty
        ? cursor = 'a0'
        : cursor =
            'a${pages.value.last.reduce((a, b) => max(a.id, b.id)).id.toString()}';

    List<Comment> comments = await client.comments(postID, cursor);
    comments.sort((a, b) =>
        DateTime.parse(a.creation).compareTo(DateTime.parse(b.creation)));
    return comments;
  }
}
