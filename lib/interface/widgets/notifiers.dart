import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

abstract class ProxyValueNotifier<T, P extends Listenable>
    extends ChangeNotifier implements ValueNotifier<T> {
  ProxyValueNotifier({required P this.parent}) {
    parent!.addListener(_updateValue);
    _value = fromParent() as T;
  }

  ProxyValueNotifier.single(T value) : parent = null {
    _value = value;
  }

  final P? parent;

  late T _value;

  void _updateValue() {
    T? updated = fromParent();
    if (updated != null) {
      _value = updated;
      notifyListeners();
    }
  }

  @protected
  T? fromParent();

  @protected
  void toParent(T value);

  bool get orphan => parent == null || fromParent() == null;

  @override
  T get value => _value;

  @override
  set value(T value) {
    if (orphan) {
      _value = value;
      notifyListeners();
    }
    toParent(value);
  }

  @override
  void dispose() {
    parent?.removeListener(_updateValue);
    super.dispose();
  }
}

class ListenableListener extends StatefulWidget {
  const ListenableListener({
    super.key,
    required this.child,
    required this.listenable,
    this.listener,
    this.initialize = true,
  });

  final Widget child;
  final Listenable listenable;
  final VoidCallback? listener;
  final bool initialize;

  @override
  State<ListenableListener> createState() => _ListenableListenerState();
}

class _ListenableListenerState extends State<ListenableListener> {
  Listenable get _listenable => widget.listenable;

  @override
  void initState() {
    super.initState();
    _listenable.addListener(_handleChange);
    if (widget.initialize) {
      _handleChange();
    }
  }

  @override
  void didUpdateWidget(ListenableListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_listenable != oldWidget.listenable) {
      oldWidget.listenable.removeListener(_handleChange);
      _listenable.addListener(_handleChange);
      if (widget.initialize) {
        _handleChange();
      }
    }
  }

  @override
  void dispose() {
    _listenable.removeListener(_handleChange);
    super.dispose();
  }

  void _handleChange() {
    widget.listener?.call();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class AnimatedSelector extends StatefulWidget {
  const AnimatedSelector(
      {required this.animation,
      required this.selector,
      required this.builder,
      this.child});

  final Listenable animation;
  final List<dynamic> Function() selector;
  final TransitionBuilder builder;
  final Widget? child;

  @override
  State<AnimatedSelector> createState() => _AnimatedSelectorState();
}

class _AnimatedSelectorState extends State<AnimatedSelector> {
  List<dynamic>? values;
  Widget? cache;
  Widget? oldWidget;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        List<dynamic> selected = widget.selector();
        bool shouldRebuild = [
          oldWidget != widget,
          !const DeepCollectionEquality().equals(values, selected),
        ].any((element) => element);
        if (shouldRebuild) {
          values = selected;
          oldWidget = widget;
          cache = widget.builder(
            context,
            child,
          );
        }
        return cache!;
      },
      child: widget.child,
    );
  }
}
