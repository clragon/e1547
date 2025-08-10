import 'dart:async';

import 'package:e1547/app/app.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sub/flutter_sub.dart';

typedef _AppInitData = ({Logs logs, AppStorage storage, VoidCallback dispose});

class AppInit extends StatefulWidget {
  const AppInit({super.key, required this.child});

  final Widget child;

  static AppInitState of(BuildContext context) =>
      context.findAncestorStateOfType<AppInitState>()!;
  static AppInitState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<AppInitState>();

  @override
  State<AppInit> createState() => AppInitState();
}

class AppInitState extends State<AppInit> {
  Key _key = UniqueKey();

  void reinitialize() => setState(() => _key = UniqueKey());

  Future<_AppInitData> _init() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await DateFormatting.ensureInitialized();
    await initializeAppInfo();
    final logs = await initializeLogger();
    final storage = await initializeAppStorage();
    unawaited(initializeBackgroundTasks());
    VideoService.ensureInitialized();
    return (
      logs: logs,
      storage: storage,
      dispose: () {
        logs.close();
        storage.close();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SubFuture<_AppInitData>(
      create: _init,
      keys: [_key],
      dispose: (future) => future.then((data) => data.dispose()).ignore(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return MaterialApp(
            key: const Key('loading'),
            theme: AppTheme.dark.data,
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const AppIcon(radius: 64),
                        if (snapshot.error != null) ...[
                          const SizedBox(height: 16),
                          const Text('Failed to initialize'),
                          if (kDebugMode) ...[
                            const SizedBox(height: 8),
                            Text(snapshot.error.toString()),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        final (:logs, :storage, dispose: _) = snapshot.data!;
        return MultiProvider(
          providers: [
            Provider.value(value: logs),
            Provider.value(value: storage),
          ],
          child: widget.child,
        );
      },
    );
  }
}
