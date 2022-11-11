import 'package:collection/collection.dart';
import 'package:e1547/interface/interface.dart';
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

class SpoilerProvider extends StatefulWidget {
  const SpoilerProvider({super.key, this.child, this.builder, this.controller});

  final Widget? child;
  final TransitionBuilder? builder;
  final SpoilerController? controller;

  @override
  State<SpoilerProvider> createState() => _SpoilerProviderState();
}

class _SpoilerProviderState extends State<SpoilerProvider> {
  late SpoilerController controller = widget.controller ?? SpoilerController();

  @override
  void didUpdateWidget(covariant SpoilerProvider oldWidget) {
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller == null) {
        controller.dispose();
      }
      controller = widget.controller ?? SpoilerController();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      builder: widget.builder,
      child: widget.child,
    );
  }
}
