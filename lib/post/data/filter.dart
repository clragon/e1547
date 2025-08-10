import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/foundation.dart';

mixin PostFilterableController<KeyType> on DataController<KeyType, Post> {
  Client get client;
  PostFilterMode get filterMode;

  List<String> _denylist = [];

  Map<Post, List<String>>? _deniedPosts;
  Map<Post, List<String>>? get deniedPosts {
    if (_deniedPosts == null) return null;
    return Map.unmodifiable(_deniedPosts!);
  }

  bool _denying = true;
  bool get denying => _denying;
  set denying(bool value) {
    if (_denying == value) return;
    _denying = value;
    applyFilter();
  }

  List<String> _allowedTags = [];
  List<String> get allowedTags => List.unmodifiable(_allowedTags);
  set allowedTags(List<String> value) {
    if (const DeepCollectionEquality().equals(_allowedTags, value)) return;
    _allowedTags = List.from(value);
    applyFilter();
  }

  List<int> _allowedPosts = [];
  List<int> get allowedPosts => List.unmodifiable(_allowedPosts);

  bool isAllowed(Post post) {
    assertOwnsItem(post);
    return _allowedPosts.contains(post.id);
  }

  void allow(Post post) {
    assertOwnsItem(post);
    _allowedPosts.add(post.id);
    applyFilter();
  }

  void unallow(Post post) {
    assertOwnsItem(post);
    _allowedPosts.remove(post.id);
    applyFilter();
  }

  List<String>? getDeniers(Post post) {
    assertOwnsItem(post);
    if (_deniedPosts![post] == null) return null;
    return List.unmodifiable(_deniedPosts![post]!);
  }

  bool isDenied(Post post) => getDeniers(post) != null;

  @override
  @protected
  List<Post>? filter(List<Post>? items) {
    List<String> denylist = [];
    if (denying && filterMode != PostFilterMode.unavailable) {
      denylist = client.traits.value.denylist
          .whereNot(_allowedTags.contains)
          .toList();
    }

    Map<Post, List<String>>? previousDeniedPosts;
    if (listEquals(_denylist, denylist)) {
      previousDeniedPosts = _deniedPosts;
    } else {
      _denylist = denylist;
    }

    _deniedPosts = {};
    List<Post>? result = super.filter(items);
    if (result != null) {
      result = {for (final p in result) p.id: p}.values.toList();
    }

    result?.removeWhere((item) {
      if (_allowedPosts.contains(item.id)) return false;
      List<String>? deniers;
      if (previousDeniedPosts?.containsKey(item) ?? false) {
        deniers = previousDeniedPosts![item]!;
      } else {
        deniers = item.getDeniers(denylist).toList();
      }
      if (deniers.isNotEmpty) {
        _deniedPosts![item] = deniers;
        if (filterMode != PostFilterMode.plain) return true;
      }
      return false;
    });
    return result;
  }

  @override
  @protected
  @mustCallSuper
  void reset() {
    _deniedPosts = null;
    _allowedPosts = [];
    super.reset();
  }
}

enum PostFilterMode { unavailable, filtering, plain }
