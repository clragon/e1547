import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

/// Provides spoilering and unspoilering text segments.
class SpoilerController extends ChangeNotifier {
  List<String> _unspoilered = [];

  void _with(List<String> Function(List<String> value) call) {
    List<String> result = call(List.from(_unspoilered));
    if (!const DeepCollectionEquality().equals(_unspoilered, result)) {
      _unspoilered = result;
      notifyListeners();
    }
  }

  /// Whether a given text segment is currently spoilered.
  bool isSpoilered(String text) => !_unspoilered.contains(text);

  /// Unspoilers a text segment.
  void unspoiler(String text) => _with((value) => value..add(text));

  /// Restoers spoiler on a given text segment.
  void respoiler(String text) => _with((value) => value..remove(text));

  /// Toggles the spoiler status of a text segment.
  void toggle(String text) =>
      isSpoilered(text) ? unspoiler(text) : respoiler(text);
}
