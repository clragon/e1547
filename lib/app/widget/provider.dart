/// This file contains global, app-wide default providers.
///
/// They are not meant for usage further down the tree.
/// Using them in such a manner could cause conflicts,
/// because no two controllers should be attached to global singletons.
library;

import 'dart:io';

import 'package:e1547/app/app.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_sub/flutter_sub.dart';

class IdentityServiceProvider
    extends
        SubChangeNotifierProvider3<
          AppStorage,
          Settings,
          ClientFactory,
          IdentityService
        > {
  IdentityServiceProvider({super.child, TransitionBuilder? builder})
    : super(
        create: (context, storage, settings, factory) => IdentityService(
          database: storage.sqlite,
          onCreate: factory.createDefaultIdentity,
        ),
        builder: (context, child) => Consumer2<IdentityService, Settings>(
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
                errorToString: (error) => 'Failed to activate identity: $error',
              ),
            ),
          ),
          child: child,
        ),
      );
}

class TraitsServiceProvider
    extends
        SubChangeNotifierProvider3<
          AppStorage,
          IdentityService,
          ClientFactory,
          TraitsService
        > {
  TraitsServiceProvider({super.child, TransitionBuilder? builder})
    : super(
        create: (context, storage, identities, factory) => TraitsService(
          database: storage.sqlite,
          onCreate: (id) async {
            Identity? identity = await identities.getOrNull(id);
            if (identity == null) return null;
            return factory.createDefaultTraits(identity);
          },
        ),
        builder: (context, child) => Consumer2<TraitsService, IdentityService>(
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

class SettingsProvider extends SubProvider<AppStorage, Settings> {
  SettingsProvider({super.child, TransitionBuilder? builder})
    : super(
        create: (context, databases) => Settings(databases.preferences),
        builder: (context, child) =>
            PrivateTextFields(child: builder?.call(context, child) ?? child!),
      );
}

class ClientFactoryProvider extends SubProvider0<ClientFactory> {
  ClientFactoryProvider({super.child, super.builder})
    : super(create: (context) => ClientFactory());
}

class ClientProvider
    extends
        SubProvider4<
          AppStorage,
          IdentityService,
          TraitsService,
          ClientFactory,
          Domain
        > {
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
          context.watch<IdentityService>().identity,
          context.watch<TraitsService>(), // notifier is created per identity
          context.watch<AppStorage>().httpCache,
        ],
        dispose: (context, domain) => domain.dispose(),
      );
}

class CacheManagerProvider
    extends SubProvider<IdentityService, BaseCacheManager> {
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
  Future<FileServiceResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    return super.get(
      url,
      headers: {
        ...headers ?? {},
        HttpHeaders.userAgentHeader: AppInfo.instance.userAgent,
        ...?identity.headers,
      },
    );
  }
}

class AppInfoClientProvider extends SubProvider0<AppInfoClient?> {
  AppInfoClientProvider({super.child, super.builder})
    : super(create: (context) => AppInfoClient());
}
