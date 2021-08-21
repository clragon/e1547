import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PostController extends DataController<Post>
    with SearchableDataMixin, HostableDataMixin, RefreshableDataMixin {
  Future<List<Post>> Function(String search, int page)? provider;
  ValueNotifier<List<String>> allowed = ValueNotifier([]);
  Map<String, List<Post>> denied = {};
  late ValueNotifier<bool> denying;
  late ValueNotifier<String> search;
  List<Post> posts = [];
  bool canSearch;
  bool canDeny;

  PostController({
    this.provider,
    String? search,
    bool denying = true,
    this.canSearch = true,
    this.canDeny = true,
  }) : this.search = ValueNotifier(sortTags(search ?? '')) {
    this.denying = ValueNotifier(denying);
    [allowed, this.denying, settings.denylist]
        .forEach((element) => element.addListener(reapplyFilter));
  }

  Future<List<Post>> filter(List<Post> items) async {
    List<String> denylist = [];
    if (denying.value && canDeny) {
      denylist = (await settings.denylist.value)
          .where((line) => !allowed.value.contains(line))
          .toList();
    }

    for (Post item in items) {
      String? denier = await item.getDenier(denylist);
      if (denier != null) {
        if (denied[denier] == null) {
          denied[denier] = [];
        }
        denied[denier]!.add(item);
      }
      item.isBlacklisted = denier != null;
    }

    List<Post> newPosts =
        items.where((element) => !element.isBlacklisted).toList();
    return newPosts;
  }

  Future<void> reapplyFilter() async {
    denied = {};
    this.value = PagingState(
      nextPageKey: this.nextPageKey,
      itemList: await filter(posts),
    );
  }

  @override
  Future<List<Post>> provide(int page) async {
    List<Post> nextPage;
    if (provider != null) {
      nextPage = await provider!(search.value, page);
    } else {
      nextPage = await client.posts(search.value, page);
    }
    posts.addAll(nextPage);
    return filter(nextPage);
  }

  @override
  Future<void> refresh({bool background = false}) async {
    posts = [];
    denied = {};
    super.refresh(background: background);
  }

  @override
  void disposeItems(List<Post> posts) async {
    if (itemList != null) {
      itemList!.forEach((post) => post.dispose());
    }
  }

  @override
  void dispose() {
    [allowed, denying, settings.denylist]
        .forEach((element) => element.removeListener(reapplyFilter));
    [
      allowed,
      denying,
    ].forEach((element) => element.dispose());
    super.dispose();
  }
}
