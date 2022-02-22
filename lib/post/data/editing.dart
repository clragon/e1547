import 'package:flutter/material.dart';

import 'post.dart';

class PostEdit {
  final String? editReason;
  final Rating? rating;
  final String? description;
  final int? parentId;
  final List<String>? sources;
  final Map<String, List<String>>? tags;

  PostEdit({
    required this.editReason,
    required this.rating,
    required this.description,
    required this.parentId,
    required this.sources,
    required this.tags,
  });

  factory PostEdit.fromPost(Post post) {
    return PostEdit(
      rating: post.rating,
      description: post.description,
      parentId: post.relationships.parentId,
      sources: post.sources,
      tags: post.tags.map((key, value) => MapEntry(key, List.from(value))),
      editReason: null,
    );
  }

  PostEdit copyWith({
    String? editReason,
    Rating? rating,
    String? description,
    int? parentId,
    List<String>? sources,
    Map<String, List<String>>? tags,
  }) =>
      PostEdit(
        editReason: editReason,
        rating: rating,
        description: description,
        parentId: parentId,
        sources: sources,
        tags: tags,
      );

  Map<String, String?>? compile(Post post) {
    Map<String, String?> body = {};

    List<String> extractTags(Map<String, List<String>> tags) {
      return tags.values.reduce(
        (value, element) => List.from(value)..addAll(element),
      );
    }

    List<String> oldTags = extractTags(post.tags);
    List<String> newTags = extractTags(tags!);
    List<String> removedTags =
        oldTags.where((element) => !newTags.contains(element)).toList();
    removedTags = removedTags.map((t) => '-$t').toList();
    List<String> addedTags =
        newTags.where((element) => !oldTags.contains(element)).toList();
    List<String> tagDiff = [];
    tagDiff.addAll(removedTags);
    tagDiff.addAll(addedTags);

    if (tagDiff.isNotEmpty) {
      body.addEntries([
        MapEntry(
          'post[tag_string_diff]',
          tagDiff.join(' '),
        ),
      ]);
    }

    List<String> removedSource =
        post.sources.where((element) => !sources!.contains(element)).toList();
    removedSource = removedSource.map((s) => '-$s').toList();
    List<String> addedSource =
        sources!.where((element) => !post.sources.contains(element)).toList();
    List<String> sourceDiff = [];
    sourceDiff.addAll(removedSource);
    sourceDiff.addAll(addedSource);

    if (sourceDiff.isNotEmpty) {
      body.addEntries([
        MapEntry(
          'post[source_diff]',
          sourceDiff.join(' '),
        ),
      ]);
    }

    if (post.relationships.parentId != parentId) {
      body.addEntries([
        MapEntry(
          'post[parent_id]',
          parentId?.toString(),
        ),
      ]);
    }

    if (post.description != description) {
      body.addEntries([
        MapEntry(
          'post[description]',
          description,
        ),
      ]);
    }

    if (post.rating != rating) {
      body.addEntries([
        MapEntry(
          'post[rating]',
          rating?.name,
        ),
      ]);
    }

    if (body.isNotEmpty) {
      if (editReason?.trim().isNotEmpty ?? false) {
        body.addEntries([
          MapEntry(
            'post[edit_reason]',
            editReason!.trim(),
          ),
        ]);
      }
      return body;
    } else {
      return null;
    }
  }
}

class PostEditingController extends ValueNotifier<PostEdit?> {
  final Post post;

  PostEditingController(this.post) : super(null);

  bool get editing => value != null;

  bool get canEdit => editing && !loading;

  bool _loading = false;
  bool get loading => _loading;

  void startEditing() {
    value = PostEdit.fromPost(post);
  }

  void stopEditing() {
    _loading = false;
    value = null;
  }

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  Map<String, String?>? compile() {
    if (value == null) {
      throw StateError('Controller cannot compile with no edit data');
    }
    return value!.compile(post);
  }
}
