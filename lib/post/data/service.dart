import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/ticket/ticket.dart';

abstract class PostService {
  Future<Post> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Post>> page({
    int? page,
    int? limit,
    QueryMap? query,
    // This needs to be rearchitected.
    // - maybe extra function, e.g. pageOrdered?
    // - maybe extra PostPageOrder class?
    // - maybe special query parameters?
    bool? ordered,
    bool? orderPoolsByOldest,
    bool? orderFavoritesByAdded,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Post>> byHot({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Post>> byIds({
    required List<int> ids,
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      // TODO: this is only relevent if pools are supported
      throw UnsupportedError('byIds');

  Future<List<Post>> byTags({
    required List<String> tags,
    int? page,
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      // TODO: this is only relevant if follows are supported
      throw UnsupportedError('byTags');

  Future<List<Post>> byFavoriter({
    required String username,
    int? page,
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Post>> byUploader({
    required String username,
    int? page,
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<void> update(int postId, Map<String, String?> body);

  Future<void> vote(int postId, bool upvote, bool replace);

  Future<List<Post>> favorites({
    int? page,
    int? limit,
    QueryMap? query,
    bool? orderByAdded,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<void> addFavorite(int postId);

  Future<void> removeFavorite(int postId);

  Future<void> report(int postId, int reportId, String reason);

  Future<void> addFlag(int postId, String flag, {int? parent});

  // Technically missing flag()
  Future<List<PostFlag>> flags({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  });
}
