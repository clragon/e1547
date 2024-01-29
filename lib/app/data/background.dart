import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/traits/traits.dart';
import 'package:workmanager/workmanager.dart';

/// Handles all background tasks that the app registered.
@pragma('vm:entry-point')
void executeBackgroundTasks() => Workmanager().executeTask(
      (task, inputData) async {
        switch (task) {
          case followsBackgroundTaskKey:
            ControllerBundle bundle = await prepareBackgroundIsolate();
            FlutterLocalNotificationsPlugin notifications =
                await initializeNotifications();
            // this ensures continued scheduling on iOS.
            FollowsService allFollows = FollowsService(
                database: bundle.databases.sqlite, identity: null);
            allFollows
                .all(types: [FollowType.notify])
                .stream
                .listen(registerFollowBackgroundTask);
            List<Identity> identities = await bundle.identities.all();
            List<bool> result = [];
            for (Identity identity in identities) {
              FollowsService follows = FollowsService(
                  database: bundle.databases.sqlite, identity: identity.id);
              TraitsService settings =
                  TraitsService(database: bundle.databases.sqlite);
              await settings.activate(identity.id);
              Client client = Client(
                identity: identity,
                traits: settings.notifier,
                // cache: bundle.databases.httpCache,
              );
              result.add(await backgroundUpdateFollows(
                service: follows,
                client: client,
                notifications: notifications,
              ));
            }
            return result.every((e) => e);
          default:
            throw StateError('Background task $task is unknown!');
        }
      },
    );
