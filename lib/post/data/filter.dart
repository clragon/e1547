import 'package:e1547/domain/domain.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'filter.freezed.dart';

class PostFilter extends FilterController<Post>
    implements ValueNotifier<PostFilterValue> {
  PostFilter(this.domain, [PostFilterValue? value])
    : _value = value ?? const PostFilterValue() {
    domain.traits.addListener(_updateDenyList);
  }

  final Domain domain;

  PostFilterValue _value;

  final Map<int, _PostFilterCache> _filterCache = {};

  void _updateDenyList() {
    _filterCache.clear();
    notifyListeners();
  }

  @override
  PostFilterValue get value => _value;

  @override
  set value(PostFilterValue value) {
    if (_value == value) return;
    _value = value;
    notifyListeners();
  }

  bool get denying => value.denying;
  set denying(bool enabled) => value = value.copyWith(denying: enabled);

  List<String> get allowedEntries => value.allowedEntries;
  set allowedEntries(List<String> entries) {
    final newValue = value.copyWith(allowedEntries: entries);
    if (value == newValue) return;
    _filterCache.clear();
    value = newValue;
  }

  List<int> get allowedPosts => value.allowedPosts;
  set allowedPosts(List<int> posts) =>
      value = value.copyWith(allowedPosts: posts);

  void allow(int postId) {
    if (!allowedPosts.contains(postId)) {
      allowedPosts = [...allowedPosts, postId];
    }
  }

  void disallow(int postId) {
    allowedPosts = allowedPosts.where((id) => id != postId).toList();
  }

  void enable(String entry) {
    if (!allowedEntries.contains(entry)) {
      allowedEntries = [...allowedEntries, entry];
    }
  }

  void disable(String entry) {
    if (allowedEntries.contains(entry)) {
      allowedEntries = allowedEntries.where((e) => e != entry).toList();
    }
  }

  void toggle(String entry) {
    if (allowedEntries.contains(entry)) {
      disable(entry);
    } else {
      enable(entry);
    }
  }

  @override
  List<Post> filter(List<Post> items) {
    if (!denying) return items;
    return items.where((post) => !denies(post)).toList();
  }

  List<String> entriesFor(Post post) {
    _evictStaleEntries();

    final cached = _filterCache[post.id];
    final now = DateTime.now();

    if (cached == null || cached.hash != post.hashCode) {
      final deniers = post.getDeniers(domain.traits.value.denylist).toList();
      _filterCache[post.id] = (
        hash: post.hashCode,
        entries: deniers,
        lastAccessed: now,
      );
      return deniers;
    }

    _filterCache[post.id] = (
      hash: cached.hash,
      entries: cached.entries,
      lastAccessed: now,
    );
    return cached.entries;
  }

  void _evictStaleEntries() {
    final cutoff = DateTime.now().subtract(const Duration(minutes: 1));
    _filterCache.removeWhere((_, entry) => entry.lastAccessed.isBefore(cutoff));
  }

  bool denies(Post post) {
    if (allowedPosts.contains(post.id)) return false;
    final activeEntries = entriesFor(
      post,
    ).where((entry) => !allowedEntries.contains(entry));
    return activeEntries.isNotEmpty;
  }

  Map<int, List<String>> get postFilterEntries {
    final Map<int, List<String>> result = {};
    for (final entry in _filterCache.entries) {
      final MapEntry(:key, :value) = entry;
      if (value.entries.isNotEmpty) {
        result[key] = value.entries;
      }
    }
    return result;
  }

  @override
  void dispose() {
    domain.traits.removeListener(_updateDenyList);
    super.dispose();
  }
}

typedef _PostFilterCache = ({
  int hash,
  List<String> entries,
  DateTime lastAccessed,
});

@freezed
abstract class PostFilterValue with _$PostFilterValue {
  const factory PostFilterValue({
    @Default(true) bool denying,
    @Default([]) List<String> allowedEntries,
    @Default([]) List<int> allowedPosts,
  }) = _PostFilterValue;
}
