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
            FollowsDao allFollows = FollowsDao(
              database: bundle.storage.sqlite,
              identity: null,
            );
            allFollows
                .all(types: [FollowType.notify])
                .stream
                .listen(registerFollowBackgroundTask);

            List<Identity> identities = await bundle.identities.all();
            List<bool> result = [];

            final clientFactory = ClientFactory();

            for (final identity in identities) {
              TraitsService traits =
                  TraitsService(database: bundle.storage.sqlite);
              await traits.activate(identity.id);

              Client client = clientFactory.create(
                ClientConfig(
                  identity: identity,
                  traits: traits.notifier,
                  storage: bundle.storage,
                ),
              );

              result.add(
                await backgroundUpdateFollows(
                  client: client,
                  notifications: notifications,
                ),
              );
            }
            return result.every((e) => e);
          default:
            throw StateError('Background task $task is unknown!');
        }
      },
    );
