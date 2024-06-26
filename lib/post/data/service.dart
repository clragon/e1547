import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/ticket/ticket.dart';

enum PostFeature {
  hot,
  uploads,
  update,
  vote,
  favorite,
  report,
  flag,
}

abstract class PostService with FeatureFlagging {
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
  }) =>
      throwUnsupported(PostFeature.hot);

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
  }) =>
      throwUnsupported(PostFeature.favorite);

  Future<List<Post>> byUploader({
    required String username,
    int? page,
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      throwUnsupported(PostFeature.uploads);

  Future<void> update(int postId, Map<String, String?> body) =>
      throwUnsupported(PostFeature.update);

  Future<void> vote(int postId, bool upvote, bool replace) =>
      throwUnsupported(PostFeature.vote);

  Future<List<Post>> favorites({
    int? page,
    int? limit,
    QueryMap? query,
    bool? orderByAdded,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      throwUnsupported(PostFeature.favorite);

  Future<void> addFavorite(int postId) =>
      throwUnsupported(PostFeature.favorite);

  Future<void> removeFavorite(int postId) =>
      throwUnsupported(PostFeature.favorite);

  Future<void> report(int postId, int reportId, String reason) =>
      throwUnsupported(PostFeature.report);

  Future<void> addFlag(int postId, String flag, {int? parent}) =>
      throwUnsupported(PostFeature.flag);

  // Technically missing flag()
  Future<List<PostFlag>> flags({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      throwUnsupported(PostFeature.flag);
}
