import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

class AppLoadingScreen extends StatefulWidget {
  const AppLoadingScreen({
    super.key,
    required this.child,
  });

  final Widget child;

  static AppLoadingScreenState of(BuildContext context) => maybeOf(context)!;

  static AppLoadingScreenState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<AppLoadingScreenState>();

  @override
  State<AppLoadingScreen> createState() => AppLoadingScreenState();
}

class AppLoadingScreenState extends State<AppLoadingScreen> {
  bool _loading = true;
  bool get loading => _loading;
  set loading(bool value) => setState(() => _loading = value);
  String? get message => _message;
  set message(String? value) => setState(() => _message = value);

  String? _message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        if (loading)
          Positioned.fill(
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 300,
                      child: Center(
                        child: AppIcon(radius: 64),
                      ),
                    ),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.topCenter,
                      heightFactor: _message == null ? 0 : 1,
                      child: Text(_message ?? ''),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class AppLoadingScreenEnd extends StatefulWidget {
  const AppLoadingScreenEnd({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AppLoadingScreenEnd> createState() => _AppLoadingScreenEndState();
}

class _AppLoadingScreenEndState extends State<AppLoadingScreenEnd> {
  late AppLoadingScreenState state;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      state = AppLoadingScreen.of(context);
      state.loading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AppLoadingScreenState newState = AppLoadingScreen.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (newState != state) {
        state = newState;
        state.loading = false;
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!state.mounted) return;
      state.loading = true;
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
