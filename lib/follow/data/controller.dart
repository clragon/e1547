import 'package:e1547/follow/follow.dart';
import 'package:e1547/post/post.dart';

class FollowTimelineController extends PostController {
  FollowTimelineController({required super.domain}) : super(canSearch: false);

  @override
  Future<List<Post>> fetch(int page, bool force) async {
    final params = FollowParams()
      ..types = {FollowType.update, FollowType.notify};

    List<Follow> follows = await domain.follows.all(
      query: params.query,
      force: force,
    );
    return domain.posts.byTags(
      tags: follows
          .where((e) => !e.tags.contains(' '))
          .map((e) => e.tags)
          .toList(),
      page: page,
      force: force,
      cancelToken: cancelToken,
    );
  }
}
