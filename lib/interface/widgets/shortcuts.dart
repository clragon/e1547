import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PageIncrementIntent extends Intent {
  /// Indicates that the PageView should increment a page.
  const PageIncrementIntent();
}

class PageDecrementIntent extends Intent {
  /// Indicates that the PageView should decrement a page.
  const PageDecrementIntent();
}

class PageViewShortcuts extends StatefulWidget {
  /// Provides shortcuts for scrollviews, like switching pages.
  const PageViewShortcuts({
    super.key,
    required this.child,
    required this.controller,
    this.autoFocus = true,
  });

  /// The child in which the shortcuts should be available.
  final Widget child;

  /// The PageController of the PageView.
  final PageController controller;

  /// Whether the shortcuts should request focus for its child.
  final bool autoFocus;

  @override
  State<PageViewShortcuts> createState() => _PageViewShortcutsState();
}

class _PageViewShortcutsState extends State<PageViewShortcuts> {
  Timer? scrollTimeout;
  bool canScroll = true;
  PageController get controller => widget.controller;
  Duration animationDuration = const Duration(milliseconds: 400);

  @override
  Widget build(BuildContext context) {
    Future<void> scroll(int page) async {
      if (!canScroll) return;
      canScroll = false;
      scrollTimeout = Timer(animationDuration, () => canScroll = true);
      return controller.animateToPage(
        page,
        duration: animationDuration,
        curve: Curves.easeInOut,
      );
    }

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowLeft): PageDecrementIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight): PageIncrementIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp): Intent.doNothing,
        SingleActivator(LogicalKeyboardKey.arrowDown): Intent.doNothing,
        SingleActivator(LogicalKeyboardKey.keyA): PageDecrementIntent(),
        SingleActivator(LogicalKeyboardKey.keyD): PageIncrementIntent(),
        SingleActivator(LogicalKeyboardKey.keyW): Intent.doNothing,
        SingleActivator(LogicalKeyboardKey.keyS): Intent.doNothing,
      },
      child: Actions(
        actions: {
          PageDecrementIntent: CallbackAction<PageDecrementIntent>(
            onInvoke: (intent) async => scroll(controller.page!.round() - 1),
          ),
          PageIncrementIntent: CallbackAction<PageIncrementIntent>(
            onInvoke: (intent) async => scroll(controller.page!.round() + 1),
          ),
        },
        child: FocusScope(
          autofocus: widget.autoFocus,
          skipTraversal: true,
          child: widget.child,
        ),
      ),
    );
  }
}
