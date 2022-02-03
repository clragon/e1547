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
  Future<List<Post>> Function(String search, int page, bool force)? provider;
  ValueNotifier<List<String>> allowed = ValueNotifier([]);
  Map<String, List<Post>>? denied;
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
    for (final element in [allowed, this.denying, settings.denylist]) {
      element.addListener(reapplyFilter);
    }
  }

  List<Post> filter(List<Post> items) {
    List<String> denylist = [];
    if (denying.value && canDeny) {
      denylist = settings.denylist.value
          .where((line) => !allowed.value.contains(line))
          .toList();
    }

    denied ??= {};
    for (Post item in items) {
      String? denier = item.getDenier(denylist);
      if (denier != null) {
        if (denied![denier] == null) {
          denied![denier] = [];
        }
        denied![denier]!.add(item);
      }
      item.isBlacklisted = denier != null;
    }

    List<Post> newPosts =
        items.where((element) => !element.isBlacklisted).toList();
    return newPosts;
  }

  void reapplyFilter() {
    if (posts != null) {
      denied = null;
      value = PagingState(
        nextPageKey: nextPageKey,
        itemList: filter(posts!),
      );
    }
  }

  @override
  Future<List<Post>> provide(int page, bool force) async {
    List<Post> nextPage;
    if (provider != null) {
      nextPage = await provider!(search.value, page, force);
    } else {
      nextPage = await client.posts(page, search: search.value, force: force);
    }
    posts ??= [];
    posts!.addAll(nextPage);
    return filter(nextPage);
  }

  @override
  Future<void> refresh({bool force = false, bool background = false}) async {
    if (!await canRefresh()) {
      return;
    }
    posts = null;
    denied = null;
    await super.refresh(force: force, background: background);
  }

  @override
  void disposeItems(List<Post> items) {
    for (final post in items) {
      post.dispose();
    }
  }

  @override
  void dispose() {
    for (final element in [allowed, denying, settings.denylist]) {
      element.removeListener(reapplyFilter);
    }
    for (final element in [
      allowed,
      denying,
    ]) {
      element.dispose();
    }
    super.dispose();
  }
}
