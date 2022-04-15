import 'dart:math';

import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

late final HistoryController historyController = HistoryController();

class HistoryController extends ChangeNotifier {
  late final ValueNotifier<Map<String, HistoryCollection>> _source;

  static const int maxCount = 3000;
  static const Duration maxAge = Duration(days: 30);

  set _collection(HistoryCollection value) {
    Map<String, HistoryCollection> collections = Map.from(_source.value);
    collections[client.host] = value;
    _source.value = collections;
  }

  HistoryCollection get collection =>
      _source.value[client.host] ?? HistoryCollection.empty();

  bool get enabled => settings.writeHistory.value;

  HistoryController() {
    _source = settings.history;
    _source.addListener(notifyListeners);
    settings.writeHistory.addListener(notifyListeners);
    client.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _source.removeListener(notifyListeners);
    settings.writeHistory.removeListener(notifyListeners);
    client.removeListener(notifyListeners);
    super.dispose();
  }

  List<T> _getRecentEntries<T extends HistoryEntry>(
    List<T> entries, {
    int range = 15,
    Duration maxAge = const Duration(minutes: 10),
  }) {
    return entries.reversed
        .take(range)
        .where(
            (element) => DateTime.now().difference(element.visitedAt) < maxAge)
        .toList();
  }

  void _trimEntries() {
    List<HistoryEntry> removal = [];

    removal.addAll(collection.entries.where(
        (element) => DateTime.now().difference(element.visitedAt) > maxAge));

    if (collection.entries.length > maxCount) {
      int trash = max((collection.entries.length - maxCount),
          (maxCount / 50).clamp(100, double.infinity).round());
      removal.addAll(collection.entries.take(trash).toList());
    }

    removal = removal.toSet().toList();

    removeEntries(removal);
  }

  bool addPost(Post post) {
    if (!enabled) {
      return false;
    }
    if (_getRecentEntries(collection.posts)
        .any((element) => element.id == post.id)) {
      return false;
    }
    String? thumbnail;
    if (!post.isDeniedBy(settings.denylist.value)) {
      thumbnail = post.sample.url;
    }
    addEntry(
      PostHistoryEntry(
        visitedAt: DateTime.now(),
        id: post.id,
        thumbnail: thumbnail,
      ),
    );
    return true;
  }

  bool addTag(String tag, {String? alias, List<Post>? posts}) {
    if (!enabled) {
      return false;
    }
    List<String> thumbnails = posts
            ?.map((e) => e.sample.url)
            .where((e) => e != null)
            .cast<String>()
            .toList()
            .take(4)
            .toList() ??
        [];
    if (_getRecentEntries(collection.tags).any(
      (element) =>
          element.tags == tag &&
          DeepCollectionEquality().equals(element.thumbnails, thumbnails),
    )) {
      return false;
    }
    addEntry(
      TagHistoryEntry(
        visitedAt: DateTime.now(),
        tags: tag,
        alias: alias,
        thumbnails: thumbnails,
      ),
    );
    return true;
  }

  void addEntry(HistoryEntry entry) => addEntries([entry]);

  void addEntries(List<HistoryEntry> entries) {
    if (entries.isEmpty) {
      return;
    }
    List<PostHistoryEntry> posts = List.from(collection.posts);
    List<TagHistoryEntry> tags = List.from(collection.tags);
    for (final entry in entries) {
      if (entry is PostHistoryEntry) {
        posts.add(entry);
      } else if (entry is TagHistoryEntry) {
        tags.add(entry);
      } else {
        throw UnimplementedError(
            'No storage implementation for this HistoryEntry: $entry');
      }
    }
    _collection = collection.copyWith(
      posts: posts,
      tags: tags,
    );
    _trimEntries();
  }

  void removeEntry(HistoryEntry entry) => removeEntries([entry]);

  void removeEntries(List<HistoryEntry> entries) {
    if (entries.isEmpty) {
      return;
    }
    List<PostHistoryEntry> posts = List.from(collection.posts);
    List<TagHistoryEntry> tags = List.from(collection.tags);
    for (final entry in entries) {
      if (entry is PostHistoryEntry) {
        posts.remove(entry);
      } else if (entry is TagHistoryEntry) {
        tags.remove(entry);
      } else {
        throw UnimplementedError(
            'No storage implementation for this HistoryEntry: $entry');
      }
    }
    _collection = collection.copyWith(
      posts: posts,
      tags: tags,
    );
  }
}
