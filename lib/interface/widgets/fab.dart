import 'package:flutter/material.dart';

typedef FloatingActionButtonContextAction = Function(BuildContext context);

typedef FloatingActionButtonActionWrapper = Function(
    BuildContext context, FloatingActionButtonContextAction action);

class FloatingActionButtonController extends ChangeNotifier {
  final Widget fallbackIcon;

  Widget icon;
  FloatingActionButtonContextAction action;

  bool get hasAction => action != null;

  FloatingActionButtonController({
    this.fallbackIcon,
  });

  void setContextAction(FloatingActionButtonContextAction action,
      [Widget icon]) {
    this.action = action;
    this.icon = icon ?? fallbackIcon;
    notifyListeners();
  }

  void setAction(Function() action, [Widget icon]) =>
      setContextAction((context) => action(), icon);

  void removeAction() {
    this.action = null;
    this.icon = null;
    notifyListeners();
  }
}

class ControlledFloatingActionButton extends StatefulWidget {
  final FloatingActionButtonController controller;
  final Widget defaultIcon;
  final FloatingActionButtonContextAction defaultAction;
  final FloatingActionButtonActionWrapper actionWrapper;
  final Color backgroundColor;
  final Object heroTag;

  const ControlledFloatingActionButton({
    @required this.controller,
    this.defaultIcon,
    this.defaultAction,
    this.actionWrapper,
    this.backgroundColor,
    this.heroTag,
  });

  @override
  _ControlledFloatingActionButtonState createState() =>
      _ControlledFloatingActionButtonState();
}

class _ControlledFloatingActionButtonState
    extends State<ControlledFloatingActionButton> {
  Widget icon;
  FloatingActionButtonContextAction action;
  FloatingActionButtonActionWrapper wrapper;

  void update() {
    wrapper = widget.actionWrapper ?? (context, action) => action(context);
    icon = widget.controller.icon ?? widget.defaultIcon;
    action = widget.controller.action ?? widget.defaultAction;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(update);
    update();
  }

  @override
  void didUpdateWidget(covariant ControlledFloatingActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    update();
  }

  @override
  void dispose() {
    widget.controller.removeListener(update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: icon,
      onPressed: () => wrapper(context, action),
      backgroundColor: widget.backgroundColor,
      heroTag: widget.heroTag,
    );
  }
}
