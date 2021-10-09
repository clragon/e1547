import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PostController extends DataController<Post>
    with
        SearchableController,
        HostableController,
        RefreshableController,
        AccountableController {
  Future<List<Post>> Function(String search, int page)? provider;
  ValueNotifier<List<String>> allowed = ValueNotifier([]);
  Map<String, List<Post>> denied = {};
  late ValueNotifier<bool> denying;
  @override
  late ValueNotifier<String> search;
  List<Post>? posts;
  bool canSearch;
  bool canDeny;

  PostController({
    this.provider,
    String? search,
    bool denying = true,
    this.canSearch = true,
    this.canDeny = true,
  }) : search = ValueNotifier(sortTags(search ?? '')) {
    this.denying = ValueNotifier(denying);
    for (var element in [allowed, this.denying, settings.denylist]) {
      element.addListener(reapplyFilter);
    }
  }

  Future<List<Post>> filter(List<Post> items) async {
    List<String> denylist = [];
    if (denying.value && canDeny) {
      denylist = settings.denylist.value
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
    if (posts != null) {
      denied = {};
      value = PagingState(
        nextPageKey: nextPageKey,
        itemList: await filter(posts!),
      );
    }
  }

  @override
  Future<List<Post>> provide(int page) async {
    List<Post> nextPage;
    if (provider != null) {
      nextPage = await provider!(search.value, page);
    } else {
      nextPage = await client.posts(page, search: search.value);
    }
    posts ??= [];
    posts!.addAll(nextPage);
    return filter(nextPage);
  }

  @override
  Future<void> refresh({bool background = false}) async {
    posts = [];
    denied = {};
    super.refresh(background: background);
  }

  @override
  void disposeItems(List<Post> items) async {
    if (itemList != null) {
      for (var post in itemList!) {
        post.dispose();
      }
    }
  }

  @override
  void dispose() {
    for (var element in [allowed, denying, settings.denylist]) {
      element.removeListener(reapplyFilter);
    }
    for (var element in [
      allowed,
      denying,
    ]) {
      element.dispose();
    }
    super.dispose();
  }
}
