import 'package:e1547/app/app.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sub_provider/developer.dart';
import 'package:window_manager/window_manager.dart';

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

  /// Whether the frame is currently focused;
  bool isFocused = false;

  /// Whether the frame is currently maximized.
  bool isMaximized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        _manager = context.read<WindowManager?>();
        await initializeManager();
      },
    );
  }

  Future<void> initializeManager() async {
    if (_manager case final manager?) {
      manager.addListener(this);
      await manager.setTitleBarStyle(TitleBarStyle.hidden);
      isFullscreen = await manager.isFullScreen();
      isFocused = await manager.isFocused();
      isMaximized = await manager.isMaximized();
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final manager = context.watch<WindowManager?>();
    if (_manager != manager) {
      _manager?.removeListener(this);
      _manager = manager;
      initializeManager();
    }
  }

  @override
  void dispose() {
    _manager?.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowEnterFullScreen() => setState(() => isFullscreen = true);

  @override
  void onWindowLeaveFullScreen() => setState(() => isFullscreen = false);

  @override
  void onWindowFocus() => setState(() => isFocused = true);

  @override
  void onWindowBlur() => setState(() => isFocused = false);

  @override
  void onWindowRestore() => setState(() => isFocused = true);

  @override
  void onWindowMaximize() => setState(() => isMaximized = true);

  @override
  void onWindowUnmaximize() => setState(() => isMaximized = false);

  @override
  Widget build(BuildContext context) {
    WindowManager? manager = context.read<WindowManager?>();
    if (manager == null) return widget.child;
    return Column(
      children: [
        if (!isFullscreen)
          Material(
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
                          child: AnimatedDefaultTextStyle(
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color:
                                      isFocused ? null : dimTextColor(context),
                                ),
                            duration: defaultAnimationDuration,
                            child: Text(
                              AppInfo.instance.appName,
                            ),
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
                      icon: isMaximized
                          ? const Icon(Icons.fullscreen_exit)
                          : const Icon(Icons.fullscreen),
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
        Expanded(
          child: ClipRect(child: widget.child),
        ),
      ],
    );
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
        hoverColor: color?.withAlpha(180),
        highlightColor: color,
        icon: icon,
        onPressed: onPressed,
        splashRadius: 24,
      );
}

class WindowShortcuts extends StatelessWidget {
  /// Provides common shortcuts for desktop apps.
  const WindowShortcuts({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  /// The child in which these shortcuts should be valid.
  final Widget child;

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            navigatorKey.currentState!.maybePop(),
        const SingleActivator(LogicalKeyboardKey.f11): () async {
          WindowManager? manager = context.read<WindowManager?>();
          if (manager == null) return;
          if (await manager.isMaximized()) {
            await manager.unmaximize();
          }
          await manager.setFullScreen(!await manager.isFullScreen());
        },
      },
      child: child,
    );
  }
}

class WindowProvider extends SingleChildStatefulWidget {
  const WindowProvider({super.key});

  @override
  State<WindowProvider> createState() => _WindowProviderState();
}

class _WindowProviderState extends SingleChildState<WindowProvider> {
  WindowManager? manager;

  @override
  void initState() {
    super.initState();
    initializeWindowManager().then((manager) {
      if (!mounted) return;
      setState(() => this.manager = manager);
    });
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return Provider.value(
      value: manager,
      child: child!,
    );
  }
}
