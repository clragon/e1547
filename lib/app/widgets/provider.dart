/// This file contains global, app-wide default providers.
///
/// They are not meant for usage further down the tree.
/// Using them in such a manner could cause conflicts,
/// because no two controllers should be attached to global singletons.
library;

import 'dart:io';

import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/identity/identity.dart';
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
              builder: (context) => SubValue<Future<void>>(
                create: () => service.activate(settings.identity.value),
                keys: [service],
                builder: (context, future) => LoadingLayer(
                  future: future,
                  builder: (context, _) =>
                      builder?.call(context, child) ?? child!,
                  errorToString: (error) =>
                      'Failed to activate identity: $error',
                ),
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
            onCreate: (id) async {
              Identity? identity = await identities.getOrNull(id);
              if (identity == null) return null;
              return factory.createDefaultTraits(identity);
            },
          ),
          builder: (context, child) =>
              Consumer2<TraitsService, IdentitiesService>(
            builder: (context, traits, identities, child) =>
                SubValue<Future<void>>(
              create: () => traits.activate(identities.identity.id),
              keys: [traits, identities, identities.identity],
              builder: (context, future) => LoadingLayer(
                future: future,
                builder: (context, _) =>
                    builder?.call(context, child) ?? child!,
                errorToString: (error) => 'Failed to activate traits: $error',
              ),
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

class ClientProvider extends SubProvider4<AppStorage, IdentitiesService,
    TraitsService, ClientFactory, Client> {
  ClientProvider({super.child, super.builder})
      : super(
          create: (context, storage, identities, traits, factory) =>
              factory.create(
            ClientConfig(
              identity: identities.identity,
              traits: traits.notifier,
              storage: storage,
            ),
          ),
          keys: (context) => [
            context.watch<IdentitiesService>().identity,
            context.watch<TraitsService>(), // notifier is created per identity
            context.watch<AppStorage>().httpCache,
          ],
          dispose: (context, client) => client.dispose(),
        );
}

class CacheManagerProvider
    extends SubProvider<IdentitiesService, BaseCacheManager> {
  CacheManagerProvider({super.child, super.builder})
      : super(
          create: (context, service) => CacheManager(
            Config(
              DefaultCacheManager.key,
              stalePeriod: const Duration(days: 1),
              repo: JsonCacheInfoRepository(
                databaseName: DefaultCacheManager.key,
              ),
              fileService: _IdentityHttpFileService(service.identity),
            ),
          ),
        );
}

class _IdentityHttpFileService extends HttpFileService {
  _IdentityHttpFileService(this.identity);

  final Identity identity;

  @override
  Future<FileServiceResponse> get(String url,
      {Map<String, String>? headers}) async {
    return super.get(url, headers: {
      ...headers ?? {},
      HttpHeaders.userAgentHeader: AppInfo.instance.userAgent,
      ...?identity.headers,
    });
  }
}

class AppInfoClientProvider extends SubProvider0<AppInfoClient?> {
  AppInfoClientProvider({super.child, super.builder})
      : super(
          create: (context) => AppInfoClient(),
        );
}
