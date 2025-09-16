/// This file contains global, app-wide default providers.
///
/// They are not meant for usage further down the tree.
/// Using them in such a manner could cause conflicts,
/// because no two controllers should be attached to global singletons.
library;

import 'dart:io';

import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_sub/flutter_sub.dart';

class IdentityClientProvider
    extends
        SubChangeNotifierProvider3<
          AppStorage,
          Settings,
          ClientFactory,
          IdentityClient
        > {
  IdentityClientProvider({super.child, TransitionBuilder? builder})
    : super(
        create: (context, storage, settings, factory) => IdentityClient(
          database: storage.sqlite,
          onCreate: factory.createDefaultIdentity,
        ),
        builder: (context, child) => Consumer2<IdentityClient, Settings>(
          builder: (context, client, settings, child) => SubListener(
            listenable: client,
            listener: () => settings.identity.value = client.identity.id,
            builder: (context) => SubValue<Future<void>>(
              create: () => client.activate(settings.identity.value),
              keys: [client],
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

class TraitsClientProvider
    extends
        SubChangeNotifierProvider3<
          AppStorage,
          IdentityClient,
          ClientFactory,
          TraitsClient
        > {
  TraitsClientProvider({super.child, TransitionBuilder? builder})
    : super(
        create: (context, storage, identities, factory) => TraitsClient(
          database: storage.sqlite,
          onCreate: (id) async {
            Identity? identity = await identities.getOrNull(id);
            if (identity == null) return null;
            return factory.createDefaultTraits(identity);
          },
        ),
        builder: (context, child) => Consumer2<TraitsClient, IdentityClient>(
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
          IdentityClient,
          TraitsClient,
          ClientFactory,
          Client
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
          context.watch<IdentityClient>().identity,
          context.watch<TraitsClient>(), // notifier is created per identity
          context.watch<AppStorage>().httpCache,
        ],
        dispose: (context, client) => client.dispose(),
      );
}

class CacheManagerProvider
    extends SubProvider<IdentityClient, BaseCacheManager> {
  CacheManagerProvider({super.child, super.builder})
    : super(
        create: (context, client) => CacheManager(
          Config(
            DefaultCacheManager.key,
            stalePeriod: const Duration(days: 1),
            repo: JsonCacheInfoRepository(
              databaseName: DefaultCacheManager.key,
            ),
            fileService: _IdentityHttpFileClient(client.identity),
          ),
        ),
      );
}

class _IdentityHttpFileClient extends HttpFileService {
  _IdentityHttpFileClient(this.identity);

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
