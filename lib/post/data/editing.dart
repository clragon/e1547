import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PostEdit {
  PostEdit({
    required this.post,
    required this.editReason,
    required this.rating,
    required this.description,
    required this.parentId,
    required this.sources,
    required this.tags,
  });

  factory PostEdit.fromPost(Post post) {
    return PostEdit(
      post: post,
      rating: post.rating,
      description: post.description,
      parentId: post.relationships.parentId,
      sources: post.sources,
      tags: post.tags.map((key, value) => MapEntry(key, List.from(value))),
      editReason: null,
    );
  }

  final Post post;
  final String? editReason;
  final Rating rating;
  final String description;
  final int? parentId;
  final List<String> sources;
  final Map<String, List<String>> tags;

  PostEdit copyWith({
    Post? post,
    String? editReason,
    Rating? rating,
    String? description,
    int? parentId,
    List<String>? sources,
    Map<String, List<String>>? tags,
  }) => PostEdit(
    post: post ?? this.post,
    editReason: editReason ?? this.editReason,
    rating: rating ?? this.rating,
    description: description ?? this.description,
    parentId: parentId ?? this.parentId,
    sources: sources ?? this.sources,
    tags: tags ?? this.tags,
  );

  Map<String, String?>? toForm() {
    Map<String, String?> body = {};

    List<String> extractTags(Map<String, List<String>> tags) {
      return tags.values.reduce(
        (value, element) => List.from(value)..addAll(element),
      );
    }

    List<String> oldTags = extractTags(post.tags);
    List<String> newTags = extractTags(tags);
    List<String> removedTags =
        oldTags.where((element) => !newTags.contains(element)).toList();
    removedTags = removedTags.map((t) => '-$t').toList();
    List<String> addedTags =
        newTags.where((element) => !oldTags.contains(element)).toList();
    List<String> tagDiff = [];
    tagDiff.addAll(removedTags);
    tagDiff.addAll(addedTags);

    if (tagDiff.isNotEmpty) {
      body.addEntries([MapEntry('post[tag_string_diff]', tagDiff.join(' '))]);
    }

    List<String> removedSource =
        post.sources.where((element) => !sources.contains(element)).toList();
    removedSource = removedSource.map((s) => '-$s').toList();
    List<String> addedSource =
        sources.where((element) => !post.sources.contains(element)).toList();
    List<String> sourceDiff = [];
    sourceDiff.addAll(removedSource);
    sourceDiff.addAll(addedSource);

    if (sourceDiff.isNotEmpty) {
      body.addEntries([MapEntry('post[source_diff]', sourceDiff.join(' '))]);
    }

    if (post.relationships.parentId != parentId) {
      body.addEntries([MapEntry('post[parent_id]', parentId?.toString())]);
    }

    if (post.description != description) {
      body.addEntries([MapEntry('post[description]', description)]);
    }

    if (post.rating != rating) {
      body.addEntries([MapEntry('post[rating]', rating.name)]);
    }

    if (body.isNotEmpty) {
      if (editReason?.trim().isNotEmpty ?? false) {
        body.addEntries([MapEntry('post[edit_reason]', editReason!.trim())]);
      }
      return body;
    } else {
      return null;
    }
  }
}

class PostEditingController extends PromptActionController
    implements ValueNotifier<PostEdit?> {
  PostEditingController({required Post post}) : _post = post;

  Post _post;

  Post get post => _post;

  set post(Post value) {
    if (value == _post) return;
    _post = value;
    if (editing) {
      startEditing();
    }
  }

  PostEdit? _value;

  @override
  PostEdit? get value => _value;

  @override
  set value(PostEdit? value) {
    _value = value;
    notifyListeners();
  }

  bool get editing => value != null;

  bool get canEdit => editing && !loading;

  bool _loading = false;

  bool get loading => _loading;

  @override
  void reset() {
    super.reset();
    if (_loading) {
      stopEditing();
    }
  }

  void startEditing() => value = PostEdit.fromPost(post);

  void stopEditing() {
    _loading = false;
    value = null;
    close();
  }

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
