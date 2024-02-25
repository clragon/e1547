import 'dart:async';

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
  void setAction(ActionControllerCallback submit) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      super.setAction(submit);
    });
  }

  FutureOr<void> show(BuildContext context, Widget? child);

  FutureOr<void> showOrAction(
    BuildContext context,
    Widget child,
  ) async {
    if (action != null) {
      action!();
    } else {
      await show(context, child);
    }
  }

  FutureOr<void> showAndAction(
    BuildContext context,
    ActionControllerCallback submit,
  ) async {
    super.setAction(submit);
    action!();
    await show(context, null);
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
  FutureOr<void> show(BuildContext context, Widget? child) async {
    sheetController = Scaffold.of(context).showBottomSheet(
      (context) => PromptActions(
        controller: this,
        child: ActionIndicators(
          controller: this,
          child: child,
        ),
      ),
    );
    await sheetController!.closed.then((_) => reset());
  }
}

class DialogActionController extends PromptActionController {
  Route? _dialog;

  @override
  bool get isShown => _dialog != null;

  @override
  void close() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_dialog == null) return;
      NavigatorState? navigator = _dialog?.navigator;
      if (navigator != null) {
        if (_dialog!.isCurrent) {
          navigator.pop();
        } else {
          navigator.removeRoute(_dialog!);
        }
      }
      reset();
    });
  }

  @override
  void reset() {
    _dialog = null;
    super.reset();
  }

  @override
  void forgive() {
    super.forgive();
    close();
  }

  @override
  FutureOr<void> show(BuildContext context, Widget? child) => showDialog(
        context: context,
        builder: (context) {
          _dialog = ModalRoute.of(context);
          return PromptActions(
            controller: this,
            child: AlertDialog(
              content: ActionIndicators(
                controller: this,
                child: child,
              ),
            ),
          );
        },
      ).then((_) => reset());
}

class LoadingDialogActionController extends DialogActionController {
  @override
  FutureOr<void> show(BuildContext context, [Widget? child]) => super.show(
        context,
        ListenableBuilder(
          listenable: this,
          builder: (context, child) => PopScope(
            canPop: !isLoading,
            child: Builder(
              builder: (context) {
                if (isLoading) {
                  return const Text('Loading...');
                } else if (isError) {
                  return Text(error!.message);
                } else {
                  return const SizedBox();
                }
              },
            ),
          ),
        ),
      );
}

class _PromptActions extends InheritedNotifier<PromptActionController> {
  const _PromptActions({required super.child, required this.controller})
      : super(notifier: controller);

  final PromptActionController controller;
}

class PromptActions extends StatelessWidget {
  const PromptActions({super.key, required this.child, this.controller});

  final Widget child;
  final PromptActionController? controller;

  static PromptActionController of(BuildContext context) => maybeOf(context)!;

  static PromptActionController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_PromptActions>()?.controller;

  @override
  Widget build(BuildContext context) {
    return SubDefault<PromptActionController?>(
      value: controller,
      create: () => Theme.of(context).isDesktop
          ? DialogActionController()
          : SheetActionController(),
      dispose: (value) => value?.dispose(),
      keys: [controller, Theme.of(context).isDesktop],
      builder: (context, controller) => _PromptActions(
        controller: this.controller ?? controller!,
        child: child,
      ),
    );
  }
}

class ActionIndicators extends StatelessWidget {
  const ActionIndicators({
    super.key,
    required this.controller,
    required this.child,
  });

  final ActionController controller;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSize(
            duration: defaultAnimationDuration,
            child: AnimatedSwitcher(
              duration: defaultAnimationDuration,
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              ),
              child: controller.isError && !controller.isForgiven
                  ? Padding(
                      key: ValueKey(controller.error),
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(
                        Icons.warning_amber,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                  : controller.isLoading
                      ? const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: SizedCircularProgressIndicator(size: 24),
                        )
                      : const SizedBox(),
            ),
          ),
          if (child != null) Expanded(child: child),
        ],
      ),
    );
  }
}

class PromptFloatingActionButton extends StatelessWidget {
  const PromptFloatingActionButton({
    super.key,
    this.controller,
    required this.builder,
    required this.icon,
    this.confirmIcon,
  });

  final Widget icon;
  final Widget? confirmIcon;
  final PromptActionController? controller;
  final Widget Function(BuildContext context, ActionController actionController)
      builder;

  @override
  Widget build(BuildContext context) {
    PromptActionController controller =
        this.controller ?? PromptActions.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => FloatingActionButton(
        onPressed: controller.isLoading
            ? null
            : () => controller.showOrAction(
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
    super.key,
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
