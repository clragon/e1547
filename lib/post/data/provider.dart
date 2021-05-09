import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

import 'post.dart';
import 'tag.dart';

class PostProvider extends DataProvider<Post> {
  Future<List<Post>> Function(String search, int page) provider;
  ValueNotifier<Map<String, List<Post>>> deniedMap = ValueNotifier({});
  ValueNotifier<List<String>> allowlist = ValueNotifier([]);
  ValueNotifier<List<Post>> denied = ValueNotifier([]);
  ValueNotifier<List<Post>> posts = ValueNotifier([]);
  ValueNotifier<bool> denying = ValueNotifier(true);
  bool canSearch;
  bool canDeny;

  PostProvider({
    this.provider,
    String search,
    bool denying = true,
    this.canSearch = true,
    this.canDeny = true,
  }) : super(
          search: sortTags(search ?? ''),
        ) {
    this.denying.value = denying;
    allowlist.addListener(refresh);
    db.denylist.addListener(refresh);
    this.denying.addListener(refresh);
  }

  Future<void> refresh({List<Post> items}) async {
    items ??= this.items;

    List<String> denylist = [];
    if (denying.value && canDeny) {
      denylist = (await db.denylist.value)
          .where((line) => !allowlist.value.contains(line))
          .toList();
    }

    deniedMap.value = {};
    for (Post item in items) {
      String denier = await item.deniedBy(denylist);
      if (denier != null) {
        if (deniedMap.value[denier] == null) {
          deniedMap.value[denier] = [];
        }
        deniedMap.value[denier].add(item);
      }
      item.isBlacklisted = denier != null;
    }

    List<Post> newPosts = [];
    List<Post> newDenied = [];

    items.forEach((element) =>
        (element.isBlacklisted ? newDenied : newPosts).add(element));

    posts.value = newPosts;
    denied.value = newDenied;
    notifyListeners();
  }

  Future<void> disposePosts() async {
    items.forEach((post) => post.dispose());
  }

  @override
  Future<void> resetPages() async {
    disposePosts();
    posts.value = [];
    denied.value = [];
    deniedMap.value = {};
    super.resetPages();
  }

  @override
  Future<List<Post>> provide(int page) async {
    if (provider != null) {
      return provider(search.value, page);
    } else {
      return client.posts(search.value, page);
    }
  }

  @override
  Future<List<Post>> transform(List<Post> next) async {
    await refresh(items: [...items, ...next]);
    return super.transform(next);
  }

  @override
  void dispose() {
    disposePosts();
    [
      deniedMap,
      allowlist,
      denied,
      posts,
      denying,
    ].forEach((element) => element.dispose());
    super.dispose();
  }
}
