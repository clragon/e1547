import 'dart:io';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

/// Returns an initializes WindowManager or null the current Platform is unsupported.
Future<WindowManager?> initializeWindowManager() async {
  if ([Platform.isWindows, Platform.isLinux, Platform.isMacOS].any((e) => e)) {
    WindowManager manager = WindowManager.instance;
    await manager.ensureInitialized();
    return manager;
  }
  return null;
}

class WindowFrame extends StatefulWidget {
  const WindowFrame({super.key, required this.child});

  /// The child which the frame surrounds.
  final Widget child;

  @override
  State<WindowFrame> createState() => _WindowFrameState();
}

class _WindowFrameState extends State<WindowFrame> with WindowListener {
  /// The window manager for this frame.
  WindowManager? _manager;

  /// Whether the frame is currently in fullscreen.
  bool isFullscreen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        WindowManager? manager = context.read<WindowManager?>();
        if (manager != null) {
          _manager = manager;
          manager.addListener(this);
          manager.setTitleBarStyle(TitleBarStyle.hidden);
          bool fullscreen = await manager.isFullScreen();
          setState(() => isFullscreen = fullscreen);
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WindowManager? manager = context.read<WindowManager?>();
    if (manager != _manager) {
      _manager?.removeListener(this);
      _manager?.addListener(this);
    }
  }

  @override
  void dispose() {
    _manager?.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowEnterFullScreen() {
    super.onWindowEnterFullScreen();
    setState(() => isFullscreen = true);
  }

  @override
  void onWindowLeaveFullScreen() {
    super.onWindowLeaveFullScreen();
    setState(() => isFullscreen = false);
  }

  @override
  Widget build(BuildContext context) {
    WindowManager? manager = context.read<WindowManager?>();
    if (manager != null) {
      return Column(
        children: [
          CrossFade(
            showChild: !isFullscreen,
            child: Material(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (details) => manager.startDragging(),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(
                                top: 4, bottom: 4, left: 12, right: 8),
                            child: AppIcon(radius: 8),
                          ),
                          Expanded(
                            child: Text(
                              context.read<AppInfo>().appName,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      TitleBarButton(
                        color: Colors.green,
                        icon: const Icon(Icons.minimize),
                        onPressed: manager.minimize,
                      ),
                      TitleBarButton(
                        color: Colors.orange,
                        icon: const Icon(Icons.fullscreen),
                        onPressed: () async {
                          if (await manager.isFullScreen()) {
                            await manager.setFullScreen(false);
                          } else if (await manager.isMaximized()) {
                            await manager.unmaximize();
                          } else {
                            await manager.maximize();
                          }
                        },
                      ),
                      TitleBarButton(
                        color: Colors.red,
                        icon: const Icon(Icons.close),
                        onPressed: manager.close,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ClipRect(child: widget.child),
          ),
        ],
      );
    }
    return widget.child;
  }
}

class TitleBarButton extends StatelessWidget {
  /// A [IconButton] to be shown in the title bar of the window.
  const TitleBarButton({
    super.key,
    required this.icon,
    this.color,
    this.onPressed,
  });

  /// The icon of this button.
  final Widget icon;

  /// The color of this button. Will affect hover and highlight color.
  final Color? color;

  /// The onpressed callback for this button.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        constraints: const BoxConstraints(),
        hoverColor: color?.withOpacity(0.7),
        highlightColor: color,
        icon: icon,
        onPressed: onPressed,
        splashRadius: 24,
      );
}

class PopRouteIntent extends Intent {
  /// Called to signal that a route should be popped.
  const PopRouteIntent();
}

class FullScreenIntent extends Intent {
  /// Called when the application should go into fullscreen.
  const FullScreenIntent();
}

class WindowShortcuts extends StatelessWidget {
  /// Provides common shortcuts for desktop apps.
  const WindowShortcuts({super.key, required this.child});

  /// The child in which these shortcuts should be valid.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.escape): const PopRouteIntent(),
        LogicalKeySet(LogicalKeyboardKey.f11): const FullScreenIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          PopRouteIntent: CallbackAction<PopRouteIntent>(
            onInvoke: (intent) => context
                .read<NavigationController>()
                .navigatorKey
                .currentState
                ?.maybePop(),
          ),
          FullScreenIntent:
              CallbackAction<FullScreenIntent>(onInvoke: (intent) async {
            WindowManager? manager = context.read<WindowManager?>();
            if (manager == null) return null;
            if (await manager.isMaximized()) {
              await manager.unmaximize();
            }
            await manager.setFullScreen(!await manager.isFullScreen());
            return null;
          })
        },
        child: child,
      ),
    );
  }
}
