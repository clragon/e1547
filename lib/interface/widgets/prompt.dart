import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

abstract class PromptActionController extends ActionController {
  bool get isShown;

  void close();

  @override
  void onSuccess() => close();

  @override
  void reset();

  @override
  void setAction(ActionControllerCallback submit) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      super.setAction(submit);
    });
  }

  void show(BuildContext context, Widget child);

  void actionOrShow(BuildContext context, Widget child) {
    if (action != null) {
      action!();
    } else {
      show(context, child);
    }
  }
}

class SheetActionController extends PromptActionController {
  PersistentBottomSheetController? sheetController;

  @override
  bool get isShown => sheetController != null;

  @override
  void close() => sheetController?.close();

  @override
  void reset() {
    sheetController = null;
    super.reset();
  }

  @override
  void show(BuildContext context, Widget child) {
    sheetController = Scaffold.of(context).showBottomSheet(
      (context) => ActionBottomSheet(controller: this, child: child),
    );
    sheetController!.closed.then((_) => reset());
  }
}

class DialogActionController extends PromptActionController {
  Route? _dialog;

  @override
  bool get isShown => _dialog != null;

  @override
  void close() {
    if (_dialog == null) return;
    NavigatorState? navigator = _dialog?.navigator;
    if (navigator != null) {
      if (_dialog!.isCurrent) {
        navigator.pop();
      } else {
        navigator.removeRoute(_dialog!);
      }
    }
  }

  @override
  void reset() {
    _dialog = null;
    super.reset();
  }

  @override
  void show(BuildContext context, Widget child) {
    showDialog(
      context: context,
      builder: (context) {
        _dialog = ModalRoute.of(context);
        return AlertDialog(content: child);
      },
    ).then((_) => reset());
  }
}

class _SheetActions extends InheritedNotifier<SheetActionController> {
  const _SheetActions({required super.child, required this.controller})
      : super(notifier: controller);

  final SheetActionController controller;
}

class SheetActions extends StatelessWidget {
  const SheetActions({super.key, required this.child, this.controller});

  final Widget child;
  final SheetActionController? controller;

  static SheetActionController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SheetActions>()!.controller;

  static SheetActionController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SheetActions>()?.controller;

  @override
  Widget build(BuildContext context) {
    return SubValue<SheetActionController?>(
      create: () => controller == null ? SheetActionController() : null,
      dispose: (value) => value?.dispose(),
      keys: [controller],
      builder: (context, controller) => _SheetActions(
        controller: this.controller ?? controller!,
        child: child,
      ),
    );
  }
}

class ActionBottomSheet extends StatelessWidget {
  const ActionBottomSheet({required this.controller, required this.child});

  final Widget child;
  final SheetActionController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) => Padding(
        padding: const EdgeInsets.all(10).copyWith(top: 0),
        child: Row(
          children: [
            CrossFade(
              showChild: controller.isLoading,
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: SizedCircularProgressIndicator(size: 16),
                ),
              ),
            ),
            CrossFade(
              showChild: controller.isError && !controller.isForgiven,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.clear,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
            Expanded(child: child!),
          ],
        ),
      ),
    );
  }
}

class PromptFloatingActionButton extends StatelessWidget {
  const PromptFloatingActionButton({
    required this.controller,
    required this.builder,
    required this.icon,
    this.confirmIcon,
  });

  final Widget icon;
  final Widget? confirmIcon;
  final PromptActionController controller;
  final Widget Function(BuildContext context, ActionController actionController)
      builder;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => FloatingActionButton(
        onPressed: controller.isLoading
            ? null
            : () => controller.actionOrShow(
                  context,
                  builder(context, controller),
                ),
        child: controller.isShown
            ? (confirmIcon ?? const Icon(Icons.check))
            : icon,
      ),
    );
  }
}

class SheetFloatingActionButton extends StatelessWidget {
  const SheetFloatingActionButton({
    required this.builder,
    required this.actionIcon,
    this.controller,
    this.confirmIcon,
  });

  final IconData actionIcon;
  final IconData? confirmIcon;
  final SheetActionController? controller;
  final Widget Function(BuildContext context, ActionController actionController)
      builder;

  @override
  Widget build(BuildContext context) {
    return SubDefault<SheetActionController>(
      value: controller ?? SheetActions.maybeOf(context),
      create: () => SheetActionController(),
      dispose: (value) => value.dispose(),
      builder: (context, controller) => PromptFloatingActionButton(
        controller: controller,
        builder: builder,
        confirmIcon: confirmIcon != null ? Icon(confirmIcon) : null,
        icon: Icon(actionIcon),
      ),
    );
  }
}

Future<T?> showDefaultSlidingBottomSheet<T>(
  BuildContext context,
  SheetBuilder builder, {
  SnapSpec snapSpec = const SnapSpec(snappings: [0.6, SnapSpec.expanded]),
  SheetBuilder? footerBuilder,
}) async {
  return showSlidingBottomSheet<T>(
    context,
    builder: (context) => defaultSlidingSheetDialog(
      context,
      builder,
      snapSpec: snapSpec,
      footerBuilder: footerBuilder,
    ),
  );
}

SlidingSheetDialog defaultSlidingSheetDialog(
  BuildContext context,
  SheetBuilder builder, {
  SnapSpec snapSpec = const SnapSpec(snappings: [0.6, SnapSpec.expanded]),
  SheetBuilder? footerBuilder,
}) {
  return SlidingSheetDialog(
    scrollSpec: const ScrollSpec(physics: ClampingScrollPhysics()),
    duration: const Duration(milliseconds: 400),
    avoidStatusBar: true,
    isBackdropInteractable: true,
    cornerRadius: 16,
    cornerRadiusOnFullscreen: 0,
    maxWidth: 600,
    headerBuilder: (context, state) => const SheetHandle(),
    footerBuilder: footerBuilder,
    builder: builder,
    snapSpec: snapSpec,
  );
}

class DefaultSheetBody extends StatelessWidget {
  const DefaultSheetBody({
    this.title,
    required this.body,
  });

  final Widget? title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: DefaultTextStyle(
                      style: Theme.of(context).textTheme.titleLarge!,
                      child: title!,
                    ),
                  ),
                ],
              ),
            ),
          body,
        ],
      ),
    );
  }
}

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Theme.of(context).iconTheme.color!,
          ),
          height: 3,
          width: 32,
        ),
      ],
    );
  }
}
