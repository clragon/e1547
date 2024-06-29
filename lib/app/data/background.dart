import 'dart:async';

import 'package:e1547/app/app.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/logs/logs.dart';
import 'package:workmanager/workmanager.dart';

/// Handles all background tasks that the app registered.
@pragma('vm:entry-point')
void executeBackgroundTasks() => Workmanager().executeTask(
      (task, inputData) async {
        final logger = Logger('BackgroundTasks');
        ControllerBundle bundle = await setupBackgroundIsolate();

        bundle.cancelToken.whenCancel.then((e) {
          logger.info('Task $task was cancelled: ${e.error}');
        });
        await Future.value(); // wait a tick in case already cancelled

        if (bundle.cancelToken.isCancelled) return true;

        Timer(
          // Android forces a 10 minute timeout on background tasks.
          // We generally don't want to run for that long, so we'll
          // cancel any task that runs for more than 5 minutes.
          // This gives us ample time to shut down gracefully.
          const Duration(minutes: 5),
          () => bundle.cancelToken.cancel('Took too long to complete'),
        );

        FlutterLocalNotificationsPlugin notifications =
            await initializeNotifications();

        try {
          switch (task) {
            case followsBackgroundTaskKey:
              return runFollowUpdates(
                bundle: bundle,
                notifications: notifications,
              );
            default:
              throw StateError('Task $task is unknown!');
          }
        } on Object catch (e, stack) {
          logger.severe('Failed executing Task $task', e, stack);
          rethrow;
        } finally {
          await teardownBackgroundIsolate(bundle);
        }
      },
    );
