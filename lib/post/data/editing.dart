import 'package:flutter/material.dart';

import 'post.dart';

class PostEditingController extends ChangeNotifier {
  Post post;

  PostEditingController(this.post);

  bool _isEditing = false;
  bool _isLoading = false;
  String? _editReason;
  Rating? _rating;
  String? _description;
  int? _parentId;
  List<String>? _sources;
  Map<String, List<String>>? _tags;

  bool get isEditing => _isEditing;
  bool get isLoading => _isLoading;
  String? get editReason => _editReason;
  Rating? get rating => _rating;
  String? get description => _description;
  int? get parentId => _parentId;
  List<String>? get sources => _sources;
  Map<String, List<String>>? get tags => _tags;

  set isEditing(bool value) {
    _isEditing = value;
    if (value) {
      rating = post.rating;
      description = post.description;
      parentId = post.relationships.parentId;
      sources = post.sources;
      tags = post.tags.map((key, value) => MapEntry(key, List.from(value)));
      notifyListeners();
    } else {
      reset();
    }
  }

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set editReason(String? value) {
    _editReason = value;
    notifyListeners();
  }

  set rating(Rating? value) {
    _rating = value;
    notifyListeners();
  }

  set description(String? value) {
    _description = value;
    notifyListeners();
  }

  set parentId(int? value) {
    _parentId = value;
    notifyListeners();
  }

  set sources(List<String>? value) {
    _sources = value;
    notifyListeners();
  }

  set tags(Map<String, List<String>>? value) {
    _tags = value;
    notifyListeners();
  }

  void reset() {
    isLoading = false;
    editReason = null;
    rating = null;
    description = null;
    parentId = null;
    sources = null;
    tags = null;
    notifyListeners();
  }

  Map<String, String?>? compile() {
    if (!isEditing) {
      assert(false,
          'Tried to compile PostEditingController data while not editing!');
      return null;
    }

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
          parentId?.toString() ?? '',
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
          ratingValues.reverse![rating],
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
    }
  }
}
