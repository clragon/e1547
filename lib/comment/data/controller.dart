import 'dart:math';

import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';

import 'comment.dart';

class CommentController extends RawDataController<String, Comment>
    with RefreshableDataMixin {
  final int postId;

  CommentController({required this.postId}) : super(firstPageKey: 'a0');

  @override
  Future<List<Comment>> provide(String page) async {
    List<Comment> comments = await client.comments(postId, page);
    comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return comments;
  }

  @override
  String provideNextPageKey(String current, List<Comment> items) {
    return items.isEmpty
        ? firstPageKey
        : 'a${items.map((post) => post.id).reduce(max).toString()}';
  }
}
