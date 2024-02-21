import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/ticket/ticket.dart';

enum PostFeature {
  update,
  favorite,
  report,
  flag,
}

abstract class PostsClient with FeatureFlagging {
  Future<Post> post(
    int postId, {
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Post>> posts({
    int? page,
    int? limit,
    QueryMap? query,
    // TODO: Implement these
    /*
    bool? ordered,
    bool? orderPoolsByOldest,
    bool? orderFavoritesByAdded,
     */
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Post>> postsByIds({
    required List<int> ids,
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Post>> postsByTags({
    required List<String> tags,
    int page,
    int? limit,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<void> updatePost(int postId, Map<String, String?> body) =>
      throwUnsupported(PostFeature.update);

  Future<void> votePost(int postId, bool upvote, bool replace) =>
      throwUnsupported(PostFeature.update);

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

  Future<void> reportPost(int postId, int reportId, String reason) =>
      throwUnsupported(PostFeature.report);

  Future<void> flagPost(int postId, String flag, {int? parent}) =>
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
