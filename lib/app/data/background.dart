import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:workmanager/workmanager.dart';

/// Handles all background tasks that the app registered.
@pragma('vm:entry-point')
void executeBackgroundTasks() => Workmanager().executeTask(
      (task, inputData) async {
        switch (task) {
          case followsBackgroundTask:
            ControllerBundle bundle = await prepareBackgroundIsolate();
            FlutterLocalNotificationsPlugin notifications =
                await initializeNotifications();
            // this ensures continued scheduling on iOS.
            bundle.follows.watchAll(types: [FollowType.notify]).listen(
                registerFollowBackgroundTask);
            return backgroundUpdateFollows(
              service: bundle.follows,
              // We only update the current host as of right now
              // If we ever support hosts which arent partial mirrors of each other,
              // We will have to switch to updating all hosts.
              client: Client(
                host: bundle.clients.host,
                credentials: bundle.clients.credentials,
                userAgent: bundle.clients.userAgent,
                cache: bundle.clients.cache,
              ),
              denylist: bundle.denylist,
              notifications: notifications,
            );
          default:
            throw StateError('Background task $task is unknown!');
        }
      },
    );
