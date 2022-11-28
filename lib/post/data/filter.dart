import 'package:collection/collection.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/foundation.dart';

mixin PostFilterableController<KeyType> on FilterableController<KeyType, Post> {
  PostFilterMode get filterMode;

  DenylistService get denylist;

  Map<Post, List<String>>? _deniedPosts;

  Map<Post, List<String>>? get deniedPosts => _deniedPosts.maybeUnmodifiable();

  bool _denying = true;

  bool get denying => _denying;

  set denying(bool value) {
    if (_denying == value) return;
    _denying = value;
    refilter();
  }

  List<String> _allowedTags = [];

  List<String> get allowedTags => List.unmodifiable(_allowedTags);

  set allowedTags(List<String> value) {
    if (const DeepCollectionEquality().equals(_allowedTags, value)) return;
    _allowedTags = List.from(value);
    refilter();
  }

  List<int> _allowedPosts = [];

  List<int> get allowedPosts => List.unmodifiable(_allowedPosts);

  List<String>? getDeniers(Post post) {
    assertOwnsItem(post);
    return _deniedPosts![post].maybeUnmodifiable();
  }

  bool isDenied(Post post) => getDeniers(post) != null;

  bool isAllowed(Post post) {
    assertOwnsItem(post);
    return _allowedPosts.contains(post.id);
  }

  void allow(Post post) {
    assertOwnsItem(post);
    _allowedPosts.add(post.id);
    refilter();
  }

  void unallow(Post post) {
    assertOwnsItem(post);
    _allowedPosts.remove(post.id);
    refilter();
  }

  @override
  @protected
  List<Post> filter(List<Post> items) {
    List<String> denylist = [];
    if (denying && filterMode != PostFilterMode.unavailable) {
      denylist = this.denylist.items.whereNot(_allowedTags.contains).toList();
    }

    _deniedPosts ??= {};
    List<Post> result = {for (final p in items) p.id: p}.values.toList();

    result.removeWhere((item) {
      if (_allowedPosts.contains(item.id)) return false;
      List<String>? deniers = item.getDeniers(denylist);
      if (deniers != null) {
        _deniedPosts![item] = deniers;
        if (filterMode != PostFilterMode.plain) {
          return true;
        }
      }
      return false;
    });
    return result;
  }

  @override
  @protected
  void refilter() {
    if (rawItemList == null) return;
    _deniedPosts = null;
    super.refilter();
  }

  @override
  @protected
  @mustCallSuper
  void reset({bool hasLoaded = false}) {
    if (hasLoaded) {
      _deniedPosts = null;
      _allowedPosts = [];
    }
    super.reset(hasLoaded: hasLoaded);
  }
}

enum PostFilterMode {
  unavailable,
  filtering,
  plain,
}
