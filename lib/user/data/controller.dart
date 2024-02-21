import 'package:e1547/post/post.dart';

class UserFavoritesController extends PostsController {
  UserFavoritesController({
    required this.user,
    required super.client,
  });

  final String user;

  @override
  Future<List<Post>> fetch(int page, bool force) {
    return client.posts.byFavoriter(
      username: user,
      page: page,
      force: force,
      cancelToken: cancelToken,
    );
  }
}

class UserUploadsController extends PostsController {
  UserUploadsController({
    required this.user,
    required super.client,
  });

  final String user;

  @override
  Future<List<Post>> fetch(int page, bool force) {
    return client.posts.byUploader(
      username: user,
      page: page,
      force: force,
      cancelToken: cancelToken,
    );
  }
}
