import 'dart:async';
import 'dart:io';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:local_auth/local_auth.dart';

class LockScreen extends StatefulWidget {
  final Widget child;

  const LockScreen({required this.child});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with ListenerCallbackMixin {
  @override
  Map<Listenable, VoidCallback> get listeners => {
        settings.appPin: lock,
        settings.biometricAuth: lock,
      };

  Object _instance = Object();

  bool get biometrics =>
      (settings.biometricAuth.value && (Platform.isAndroid || Platform.isIOS));
  String? get pin => settings.appPin.value;
  bool get enabled => pin != null || biometrics;

  late bool locked = enabled;

  void lock() {
    _instance = Object();
    setState(() => locked = true);
  }

  void unlock() {
    _instance = Object();
    setState(() => locked = false);
  }

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
        didOpened: biometrics
            ? () => tryLocalAuth(
                  context: context,
                  onSuccess: unlock,
                )
            : null,
        didUnlocked: unlock,
        screenLockConfig: ScreenLockConfig(
          themeData: Theme.of(context).copyWith(
            textTheme: TextTheme(
              headline1:
                  Theme.of(context).textTheme.headline1!.copyWith(fontSize: 20),
              bodyText2:
                  Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 18),
            ),
          ),
        ),
        secretsConfig: SecretsConfig(
          spacing: 12,
          secretConfig: SecretConfig(
            borderColor: Theme.of(context).textTheme.bodyText2!.color!,
            enabledColor: Theme.of(context).textTheme.bodyText2!.color!,
          ),
        ),
        keyPadConfig: const KeyPadConfig(
          buttonConfig: StyledInputConfig(
            textStyle: TextStyle(
              fontSize: 36,
            ),
            height: 68,
            width: 68,
          ),
        ),
      );
    } else if (biometrics) {
      lock = BiometricsLockScreen(
        onSuccess: unlock,
      );
    }

    bool showLock = lock != null && enabled && locked;

    return Stack(
      fit: StackFit.passthrough,
      children: [
        ExcludeFocus(
          excluding: showLock,
          child: Offstage(
            offstage: showLock,
            child: widget.child,
          ),
        ),
        if (showLock) KeyedSubtree(key: ObjectKey(_instance), child: lock)
      ],
    );
  }
}

class BiometricsLockScreen extends StatefulWidget {
  final VoidCallback onSuccess;

  const BiometricsLockScreen({super.key, required this.onSuccess});

  @override
  State<BiometricsLockScreen> createState() => _BiometricsLockScreenState();
}

class _BiometricsLockScreenState extends State<BiometricsLockScreen> {
  bool failed = false;

  Future<void> tryAuth() async {
    setState(() => failed = false);
    tryLocalAuth(
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
            Text(
              failed ? 'Failed to authenticate' : 'Please authenticate',
              style:
                  Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 20),
            ),
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
    ScaffoldMessenger.of(context).showSnackBar(
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
  screenLock(
    title: const Text('Enter new PIN'),
    confirmTitle: const Text('Confirm new PIN'),
    context: context,
    correctString: '',
    confirmation: true,
    didConfirmed: (result) {
      completer.complete(result);
      Navigator.of(context).maybePop();
    },
    didCancelled: () {
      completer.complete(null);
      Navigator.of(context).maybePop();
    },
    screenLockConfig: ScreenLockConfig(
      themeData: Theme.of(context).copyWith(
        textTheme: TextTheme(
          headline1:
              Theme.of(context).textTheme.headline1!.copyWith(fontSize: 20),
          bodyText2:
              Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 18),
        ),
      ),
    ),
    secretsConfig: SecretsConfig(
      spacing: 12,
      secretConfig: SecretConfig(
        borderColor: Theme.of(context).textTheme.bodyText2!.color!,
        enabledColor: Theme.of(context).textTheme.bodyText2!.color!,
      ),
    ),
    keyPadConfig: const KeyPadConfig(
      buttonConfig: StyledInputConfig(
        textStyle: TextStyle(
          fontSize: 36,
        ),
        height: 68,
        width: 68,
      ),
    ),
  );

  return completer.future;
}
