/// This file contains global, app-wide default providers.
///
/// They are not meant for usage further down the tree.
/// Using them in such a manner could cause conflicts,
/// because no two controllers should be attached to global singletons.
library;

import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_sub/flutter_sub.dart';

class IdentitiesServiceProvider extends SubChangeNotifierProvider3<AppStorage,
    Settings, ClientFactory, IdentitiesService> {
  IdentitiesServiceProvider({
    super.child,
    TransitionBuilder? builder,
  }) : super(
          create: (context, storage, settings, factory) => IdentitiesService(
            database: storage.sqlite,
            onCreate: factory.createDefaultIdentity,
          ),
          builder: (context, child) => Consumer2<IdentitiesService, Settings>(
            builder: (context, service, settings, child) => SubListener(
              listenable: service,
              listener: () => settings.identity.value = service.identity.id,
              builder: (context) => SubFuture<void>(
                create: () => service.activate(settings.identity.value),
                keys: [service],
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Container(
                      color: Theme.of(context).colorScheme.background,
                    );
                  }
                  return builder?.call(context, child) ?? child!;
                },
              ),
            ),
            child: child,
          ),
        );
}

class TraitsServiceProvider extends SubChangeNotifierProvider3<AppStorage,
    IdentitiesService, ClientFactory, TraitsService> {
  TraitsServiceProvider({
    super.child,
    TransitionBuilder? builder,
  }) : super(
          create: (context, storage, identities, factory) => TraitsService(
            database: storage.sqlite,
            onCreate: (id) async => factory.createDefaultTraits(
              await identities.get(id),
            ),
          ),
          builder: (context, child) =>
              Consumer2<TraitsService, IdentitiesService>(
            builder: (context, traits, identities, child) => SubFuture<void>(
              create: () => traits.activate(identities.identity.id),
              keys: [traits, identities],
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Container(
                    color: Theme.of(context).colorScheme.background,
                  );
                }
                return builder?.call(context, child) ?? child!;
              },
            ),
            child: child,
          ),
        );
}

class HistoriesServiceProvider extends SubChangeNotifierProvider3<AppStorage,
    IdentitiesService, Settings, HistoriesService> {
  HistoriesServiceProvider({
    super.child,
    TransitionBuilder? builder,
  }) : super(
          create: (context, storage, identities, settings) => HistoriesService(
            database: storage.sqlite,
            identity: identities.identity.id,
            enabled: settings.writeHistory.value,
            trimming: settings.trimHistory.value,
          ),
          keys: (context) => [context.watch<IdentitiesService>().identity.id],
          builder: (context, child) => SubListener(
            listenable: context.watch<HistoriesService>(),
            listener: () {
              HistoriesService service = context.read<HistoriesService>();
              Settings settings = context.read<Settings>();
              settings.writeHistory.value = service.enabled;
              settings.trimHistory.value = service.trimming;
            },
            builder: (context) => builder?.call(context, child) ?? child!,
          ),
        );
}

class FollowsProvider
    extends SubProvider2<AppStorage, IdentitiesService, FollowsService> {
  FollowsProvider({
    super.child,
    TransitionBuilder? builder,
  }) : super(
          create: (context, storage, identities) => FollowsService(
            database: storage.sqlite,
            identity: identities.identity.id,
          ),
          keys: (context) => [context.watch<IdentitiesService>().identity.id],
          builder: (context, child) {
            return SubChangeNotifierProvider<FollowsService, FollowsUpdater>(
              create: (context, service) {
                FollowsUpdater updater = FollowsUpdater(service: service);
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => updater.update(client: context.read<Client>()),
                );
                return updater;
              },
              builder: (context, child) =>
                  builder?.call(context, child) ?? child!,
              child: child,
            );
          },
        );
}

class SettingsProvider extends SubProvider<AppStorage, Settings> {
  SettingsProvider({super.child, super.builder})
      : super(
          create: (context, databases) => Settings(
            databases.preferences,
          ),
        );
}

class ClientFactoryProvider extends SubProvider0<ClientFactory> {
  ClientFactoryProvider({super.child, super.builder})
      : super(create: (context) => ClientFactory());
}

class ClientProvider extends SubProvider5<AppStorage, IdentitiesService,
    TraitsService, AppInfo, ClientFactory, Client> {
  ClientProvider({super.child, super.builder})
      : super(
          create: (context, storage, identities, traits, info, factory) =>
              factory.create(
            ClientConfig(
              identity: identities.identity,
              traits: traits.notifier,
              userAgent: info.userAgent,
              cache: storage.httpCache,
            ),
          ),
          keys: (context) => [
            context.watch<IdentitiesService>().identity,
            context.watch<AppStorage>().httpCache,
            context.watch<AppInfo>().userAgent,
          ],
          dispose: (context, client) => client.dispose(),
        );
}

class CacheManagerProvider extends Provider<BaseCacheManager> {
  CacheManagerProvider({super.key, super.child, super.builder})
      : super(
          create: (context) => CacheManager(
            Config(
              DefaultCacheManager.key,
              stalePeriod: const Duration(days: 1),
            ),
          ),
        );
}
