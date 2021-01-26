import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

import 'post.dart';
import 'tag.dart';

class PostProvider extends DataProvider<Post> {
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
    for (Post item in items) {
      item.isBlacklisted = await client.isBlacklisted(item, denylist);
    }
    posts.value = items.where((item) => !item.isBlacklisted).toList();
    denied.value = items.where((item) => item.isBlacklisted).toList();
  }

  void dispose() {
    for (Post post in items) {
      post.dispose();
    }
  }
}
