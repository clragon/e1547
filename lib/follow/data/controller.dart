import 'package:e1547/follow/follow.dart';
import 'package:e1547/post/post.dart';

class FollowTimelineController extends PostsController {
  FollowTimelineController({
    required super.client,
    required this.follows,
  }) : super(canSearch: false);

  final FollowsService follows;

  @override
  Future<List<Post>> fetch(int page, bool force) async {
    return client.posts.byTags(
      tags: await (follows.all(
        types: [FollowType.update, FollowType.notify],
      ).then((e) => e.map((e) => e.tags).toList())),
      page: page,
      force: force,
      cancelToken: cancelToken,
    );
  }
}
