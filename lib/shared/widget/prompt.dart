import 'dart:async';

import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

abstract class _PromptActionRoute {
  /// Whether the dialog is open.
  bool get isOpen;

  /// Close the dialog. Idempotent.
  void close();
}

class _PromptActionDialog extends _PromptActionRoute {
  _PromptActionDialog(this.route);

  final Route route;

  @override
  bool get isOpen => route.isActive;

  @override
  void close() {
    NavigatorState? navigator = route.navigator;
    if (route.isActive) {
      if (navigator != null) {
        if (route.isCurrent) {
          navigator.pop();
        } else {
          navigator.removeRoute(route);
        }
      }
    }
  }
}

class _PromptActionSheet extends _PromptActionRoute {
  _PromptActionSheet(this.controller) {
    controller.closed.then((_) => _completed = true);
  }

  final PersistentBottomSheetController controller;
  bool _completed = false;

  @override
  bool get isOpen => !_completed;

  @override
  void close() => controller.close();
}

class PromptActionController extends ActionController {
  _PromptActionRoute? _route;

  bool get isShown => _route != null && _route!.isOpen;

  @override
  @protected
  void onForgive() => close();

  @override
  @protected
  void onSuccess() => close();

  @override
  void setAction(ActionControllerCallback submit) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      super.setAction(submit);
    });
  }

  FutureOr<void> showOrAction(BuildContext context, Widget child) async {
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

  Widget build(BuildContext context, Widget? child) => PromptActions(
    controller: this,
    child: ActionIndicators(controller: this, child: child),
  );

  FutureOr<void> show(BuildContext context, Widget? child) {
    if (Theme.of(context).isDesktop) {
      return showDialog(
        context: context,
        builder: (context) {
          _route = _PromptActionDialog(ModalRoute.of(context)!);
          return AlertDialog(
            content: SizedBox(width: 600, child: build(context, child)),
          );
        },
      ).then((_) => close());
    } else {
      final sheetController = Scaffold.of(
        context,
      ).showBottomSheet((context) => build(context, child));
      _route = _PromptActionSheet(sheetController);
      return sheetController.closed.then((_) => close());
    }
  }

  void close() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _route?.close();
      reset();
    });
  }
}

class LoadingDialogActionController extends PromptActionController {
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
      create: () => PromptActionController(),
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
                child: FadeTransition(opacity: animation, child: child),
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
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    PromptActionController controller =
        this.controller ?? PromptActions.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return FloatingActionButton(
          onPressed: controller.isLoading
              ? null
              : () => controller.showOrAction(context, builder(context)),
          child: controller.isShown
              ? (confirmIcon ?? const Icon(Icons.check))
              : icon,
        );
      },
    );
  }
}

class PromptTextFieldSuffix extends StatelessWidget {
  const PromptTextFieldSuffix({super.key, this.icon, this.controller});

  final Widget? icon;
  final PromptActionController? controller;

  @override
  Widget build(BuildContext context) {
    PromptActionController controller =
        this.controller ?? PromptActions.of(context);
    bool hasFab = Scaffold.maybeOf(context)?.hasFloatingActionButton ?? false;
    if (hasFab || !controller.isShown) {
      return const SizedBox();
    } else {
      return IconButton(
        icon: icon ?? const Icon(Icons.check),
        onPressed: controller.isLoading ? null : controller.action,
      );
    }
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
  const DefaultSheetBody({super.key, this.title, required this.body});

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
