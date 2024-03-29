import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';

class FollowTimelineController extends PostController {
  FollowTimelineController({
    required super.client,
  }) : super(canSearch: false);

  @override
  Future<List<Post>> fetch(int page, bool force) async {
    List<Follow> follows = await client.follows.all(
      query: FollowsQuery(
        types: [FollowType.update, FollowType.notify],
      ),
      force: force,
    );
    return client.posts.byTags(
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

class FollowController extends PageClientDataController<Follow> {
  FollowController({
    required this.client,
    this.types = FollowType.values,
    bool filterUnseen = false,
  }) : _filterUnseen = filterUnseen;

  @override
  final Client client;
  final List<FollowType> types;

  bool get filterUnseen => _filterUnseen;
  bool _filterUnseen;
  set filterUnseen(bool value) {
    if (_filterUnseen == value) return;
    _filterUnseen = value;
    refresh();
  }

  @override
  Future<List<Follow>> fetch(int page, bool force) {
    StreamFuture<List<Follow>> result;
    if (page == 1) {
      result = client.follows
          .all(
            query: FollowsQuery(
              types: types,
              hasUnseen: _filterUnseen,
            ),
            force: force,
          )
          .stream;
      if (_filterUnseen) {
        return result.stream.asyncExpand((event) {
          if (event.fold(0, (a, b) => a + b.unseen!) == 0) {
            return client.follows
                .all(
                  query: FollowsQuery(types: types),
                  force: force,
                )
                .stream
                .stream; // I can explain
          } else {
            return Stream.value(event);
          }
        }).future;
      }
    } else {
      result = StreamFuture.value([]);
    }
    return result;
  }
}
