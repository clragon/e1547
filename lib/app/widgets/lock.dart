import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:local_auth/local_auth.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key, required this.child});

  final Widget child;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool get biometrics => context.read<Settings>().biometricAuth.value;
  String? get pin => context.read<Settings>().appPin.value;
  bool get enabled => pin != null || biometrics;
  late bool locked = enabled;

  void lock() => setState(() => locked = true);
  void unlock() => setState(() => locked = false);

  @override
  Widget build(BuildContext context) {
    Widget? lock;

    if (pin != null) {
      lock = ScreenLock(
        title: const Text('Enter PIN'),
        correctString: pin!,
        customizedButtonChild:
            biometrics ? const Icon(Icons.fingerprint) : null,
        customizedButtonTap: biometrics
            ? () => tryLocalAuth(
                  context: context,
                  onSuccess: unlock,
                )
            : null,
        onOpened: biometrics
            ? () => tryLocalAuth(
                  context: context,
                  onSuccess: unlock,
                )
            : null,
        onUnlocked: unlock,
        config: ScreenLockConfig(themeData: Theme.of(context)),
      );
    } else if (biometrics) {
      lock = BiometricsLockScreen(
        onSuccess: unlock,
      );
    }

    bool showLock = lock != null && enabled && locked;

    return SubListener(
      listener: this.lock,
      listenable: Listenable.merge([
        context.read<Settings>().appPin,
        context.read<Settings>().biometricAuth
      ]),
      builder: (context) => HeroControllerScopePassThrough(
        child: widget.child,
        builder: (context, child) => Navigator(
          pages: [
            MaterialPage(
              child: Visibility(
                visible: !showLock,
                maintainState: true,
                child: child,
              ),
            ),
            if (showLock) MaterialPage(child: lock!),
          ],
          onPopPage: (route, result) => false,
        ),
      ),
    );
  }
}

class BiometricsLockScreen extends StatefulWidget {
  const BiometricsLockScreen({super.key, required this.onSuccess});

  final VoidCallback onSuccess;

  @override
  State<BiometricsLockScreen> createState() => _BiometricsLockScreenState();
}

class _BiometricsLockScreenState extends State<BiometricsLockScreen> {
  bool failed = false;

  Future<void> tryAuth() async {
    setState(() => failed = false);
    await tryLocalAuth(
      context: context,
      onSuccess: widget.onSuccess,
      onFailure: () => setState(() => failed = true),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => tryAuth());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.fingerprint,
              size: 60,
            ),
            const SizedBox(height: 20),
            Text(
              failed ? 'Failed to authenticate' : 'Please authenticate',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (failed)
              TextButton(
                onPressed: tryAuth,
                child: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> tryLocalAuth({
  required BuildContext context,
  VoidCallback? onSuccess,
  VoidCallback? onFailure,
}) async {
  ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
  final LocalAuthentication localAuth = LocalAuthentication();
  await localAuth.stopAuthentication();
  try {
    bool success = await localAuth.authenticate(
      localizedReason: 'Authenticate to unlock.',
      options: const AuthenticationOptions(stickyAuth: true),
    );
    if (success) {
      onSuccess?.call();
    } else {
      onFailure?.call();
    }
  } on PlatformException {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Severe failure in biometric authentication'),
        duration: Duration(milliseconds: 300),
      ),
    );
    onFailure?.call();
  }
}

Future<String?> registerPin(BuildContext context) async {
  Completer<String?> completer = Completer();
  await screenLockCreate(
    title: const Text('Enter new PIN'),
    confirmTitle: const Text('Confirm new PIN'),
    context: context,
    onConfirmed: (result) {
      completer.complete(result);
      Navigator.of(context).pop();
    },
    onCancelled: () {
      completer.complete(null);
      Navigator.of(context).pop();
    },
    config: ScreenLockConfig(themeData: Theme.of(context)),
  );

  return completer.future;
}
