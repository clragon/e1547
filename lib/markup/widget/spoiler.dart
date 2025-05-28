import 'package:collection/collection.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/markup/markup.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef SpoilerMap = Map<DTextId, SpoilerInfo>;

@immutable
class SpoilerInfo {
  const SpoilerInfo({required this.spoilered, required this.recognizer});

  final bool spoilered;
  final GestureRecognizer recognizer;

  SpoilerInfo copyWith({bool? spoilered, GestureRecognizer? recognizer}) =>
      SpoilerInfo(
        spoilered: spoilered ?? this.spoilered,
        recognizer: recognizer ?? this.recognizer,
      );
}

/// Provides spoilering and unspoilering text segments.
class SpoilerController extends ChangeNotifier
    implements ValueNotifier<SpoilerMap> {
  SpoilerController();

  SpoilerMap _value = {};

  /// The list of unspoilered ids.
  @override
  SpoilerMap get value => _value;

  @override
  set value(SpoilerMap newValue) {
    if (!mapEquals(_value, newValue)) {
      _value = newValue;
      notifyListeners();
    }
  }

  SpoilerInfo Function() _defaultInfo(DTextId id) =>
      () => SpoilerInfo(
        spoilered: true,
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            List<DTextId> spoilers = parents(id);
            DTextId? top = spoilers.firstWhereOrNull(spoilered);
            toggle(top ?? id);
          },
      );

  void _with(SpoilerMap Function(SpoilerMap value) call) {
    SpoilerMap result = call(Map.from(value));
    if (!mapEquals(value, result)) {
      value = result;
    }
  }

  /// Registers a new text segment.
  // This intentionally does not notify listeners, as that would cause a build cascade.
  void register(DTextId id) => _value.putIfAbsent(id, _defaultInfo(id));

  /// Whether a given spoiler is active
  bool spoilered(DTextId id) => value[id]?.spoilered ?? false;

  /// Whether a given text segment is hidden. This is true if any of its parents are spoilered.
  bool hidden(DTextId id) => [...parents(id), id].any(spoilered);

  /// Unspoilers a text segment.
  void unspoiler(DTextId id) => _with(
    (value) => value
      ..update(
        id,
        (e) => e.copyWith(spoilered: false),
        ifAbsent: _defaultInfo(id),
      ),
  );

  /// Restores spoiler on a given text segment.
  void respoiler(DTextId id) => _with(
    (value) => value
      ..update(
        id,
        (e) => e.copyWith(spoilered: true),
        ifAbsent: _defaultInfo(id),
      ),
  );

  /// Toggles the spoiler status of a text segment.
  void toggle(DTextId id) => spoilered(id) ? unspoiler(id) : respoiler(id);

  /// Returns the list of parents of a given text segment.
  List<DTextId> parents(DTextId id) =>
      value.keys.where(id.isContainedBy).toList();

  /// Returns the gesture recognizer for a given text segment.
  GestureRecognizer recognizer(DTextId id) {
    _with((value) => value..putIfAbsent(id, _defaultInfo(id)));
    return value[id]!.recognizer;
  }

  @override
  void dispose() {
    for (SpoilerInfo info in value.values) {
      info.recognizer.dispose();
    }
    super.dispose();
  }
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
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
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
