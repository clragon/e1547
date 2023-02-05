import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class PostsController extends PageClientDataController<Post>
    with
        PostsActionController,
        SearchableController,
        FilterableController,
        PostFilterableController,
        RefreshableController {
  PostsController({
    required this.client,
    required this.denylist,
    PostFetchCallback? fetch,
    String? search,
    bool denying = true,
    this.canSearch = true,
    this.filterMode = PostFilterMode.filtering,
  })  : _fetch = fetch,
        search = ValueNotifier<String>(sortTags(search ?? '')) {
    this.denying = denying;
    _filterNotifiers.forEach((e) => e.addListener(refilter));
  }

  factory PostsController.single({
    required int id,
    required Client client,
    required DenylistService denylist,
    PostFilterMode filterMode = PostFilterMode.plain,
  }) {
    late PostsController controller;
    return controller = PostsController(
      client: client,
      denylist: denylist,
      fetch: (search, page, force) async => [
        if (page == controller.firstPageKey)
          await controller.client.post(id, force: force),
      ],
      canSearch: false,
      filterMode: filterMode,
    );
  }

  @override
  final Client client;
  final PostFetchCallback? _fetch;

  @override
  final ValueNotifier<String> search;
  final bool canSearch;

  @override
  final PostFilterMode filterMode;
  @override
  final DenylistService denylist;
  late final List<Listenable> _filterNotifiers = [denylist];

  @override
  @protected
  Future<List<Post>> fetch(int page, bool force) async {
    if (_fetch != null) {
      return _fetch!(search.value, page, force);
    } else {
      return client.posts(
        page,
        search: search.value,
        force: force,
        cancelToken: cancelToken,
      );
    }
  }

  @override
  void dispose() {
    _filterNotifiers.forEach((e) => e.removeListener(refilter));
    super.dispose();
  }
}

typedef PostFetchCallback = Future<List<Post>> Function(
    String search, int page, bool force);

class PostsProvider extends SubChangeNotifierProvider2<Client, DenylistService,
    PostsController> {
  PostsProvider({
    Future<List<Post>> Function(
      PostsController controller,
      String search,
      int page,
      bool force,
    )?
        fetch,
    String? search,
    bool denying = true,
    bool canSearch = true,
    PostFilterMode filterMode = PostFilterMode.filtering,
    super.child,
    super.builder,
  }) : super(
          create: (context, client, denylist) {
            late PostsController controller;
            return controller = PostsController(
              client: client,
              denylist: denylist,
              fetch: fetch != null
                  ? (search, page, force) =>
                      fetch(controller, search, page, force)
                  : null,
              search: search,
              denying: denying,
              canSearch: canSearch,
              filterMode: filterMode,
            );
          },
        );

  PostsProvider.single({
    required int id,
    PostFilterMode filterMode = PostFilterMode.plain,
    super.child,
    super.builder,
  }) : super(
          create: (context, client, denylist) => PostsController.single(
            id: id,
            client: client,
            denylist: denylist,
            filterMode: filterMode,
          ),
        );
}
