import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

export 'package:expandable/expandable.dart';

class _Expandables extends InheritedWidget {
  const _Expandables({
    required super.child,
    required this.controllers,
    required this.get,
  });

  final Map<Object, ExpandableController> controllers;
  final ExpandableController Function(Object key, {bool? expanded}) get;

  @override
  bool updateShouldNotify(covariant _Expandables oldWidget) =>
      oldWidget.get != get || !mapEquals(oldWidget.controllers, controllers);
}

class Expandables extends StatefulWidget {
  const Expandables({super.key, required this.child, this.expanded = false});

  static ExpandableController of(
    BuildContext context,
    Object key, {
    bool? expanded,
  }) => context.dependOnInheritedWidgetOfExactType<_Expandables>()!.get(
    key,
    expanded: expanded,
  );

  final Widget child;
  final bool expanded;

  @override
  State<Expandables> createState() => _ExpandablesState();
}

class _ExpandablesState extends State<Expandables> {
  final Map<Object, ExpandableController> _controllers = {};

  ExpandableController get(Object key, {bool? expanded}) {
    _controllers.putIfAbsent(
      key,
      () => ExpandableController(initialExpanded: expanded ?? widget.expanded),
    );
    return _controllers[key]!;
  }

  @override
  Widget build(BuildContext context) {
    return _Expandables(
      get: get,
      controllers: _controllers,
      child: ExpandableTheme(
        data: ExpandableThemeData(
          headerAlignment: ExpandablePanelHeaderAlignment.center,
          iconColor: Theme.of(context).iconTheme.color,
        ),
        child: widget.child,
      ),
    );
  }
}
