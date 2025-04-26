import 'dart:async';

import 'package:e1547/shared/shared.dart';
import 'package:e1547/theme/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

/// Root widget to initialize all objects necessary for the app to function.
/// Shows a loading screen while initializing and a failure screen if initialization fails.
/// Non-critical operations must be handled by the caller. Errors will be treated as fatal.
class AppLoadingScreen<T> extends StatelessWidget {
  const AppLoadingScreen({
    super.key,
    required this.builder,
    required this.init,
    this.dispose,
  });

  final FutureOr<T> Function() init;
  final Widget Function(BuildContext context, T data) builder;
  final void Function(T data)? dispose;

  @override
  Widget build(BuildContext context) {
    return SubFuture<T>(
      create: () async => init(),
      dispose: (future) => future.then((data) => dispose?.call(data)),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return MaterialApp(
            theme: AppTheme.system.data,
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppIcon(
                        radius: 64,
                      ),
                      if (snapshot.error != null) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Failed to initialize',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        if (kDebugMode) ...[
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ]
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return builder(
          context,
          snapshot.data as T,
        );
      },
    );
  }
}
