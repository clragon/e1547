import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

import 'post.dart';
import 'tag.dart';

class PostProvider extends DataProvider<Post> {
  ValueNotifier<Map<String, List<Post>>> deniedMap = ValueNotifier({});
  ValueNotifier<List<String>> allowlist = ValueNotifier([]);
  ValueNotifier<List<Post>> denied = ValueNotifier([]);
  ValueNotifier<List<Post>> posts = ValueNotifier([]);
  ValueNotifier<bool> denying = ValueNotifier(true);

  PostProvider(
      {String search,
      Future<List<Post>> Function(String search, int page) provider,
      bool denying = true})
      : super(
            search: sortTags(search ?? ''),
            provider: provider ?? client.posts) {
    this.denying.value = denying;
    this.denying.addListener(refresh);
    pages.addListener(refresh);
    allowlist.addListener(refresh);
  }

  Future<void> resetPages() async {
    super.resetPages();
    dispose();
  }

  void refresh() async {
    List<String> denylist = [];
    if (denying.value) {
      denylist = (await db.denylist.value).where((line) {
        return !allowlist.value.contains(line);
      }).toList();
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
    denied.value = deniedMap.value.values.expand((element) => element).toList();
    posts.value = List<Post>.from(items)
        .where((element) => !element.isBlacklisted)
        .toList();
  }

  void dispose() {
    for (Post post in items) {
      post.dispose();
    }
  }
}
