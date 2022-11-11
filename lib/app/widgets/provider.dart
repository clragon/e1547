/// This file contains global, app-wide default providers.
/// They are not meant for usage further down the tree.
/// Using them in such a manner could cause conflicts,
/// because no two controllers should be attached to the Settings.

import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';

class HostServiceProvider extends SubChangeNotifierProvider3<AppInfo, Settings,
    EnvironmentPaths, HostService> {
  HostServiceProvider({super.child, TransitionBuilder? builder})
      : super(
          create: (context, appInfo, settings, paths) => HostService(
            defaultHost: appInfo.defaultHost,
            allowedHosts: appInfo.allowedHosts,
            host: settings.host.value,
            customHost: settings.customHost.value,
            credentials: settings.credentials.value,
            appInfo: appInfo,
            cachePath: paths.temporaryDirectory,
          ),
          builder: (context, child) => ListenableListener(
            listenable: context.watch<HostService>(),
            listener: () {
              HostService service = context.read<HostService>();
              Settings settings = context.read<Settings>();
              settings.host.value = service.host;
              settings.customHost.value = service.customHost;
            },
            child: ClientProvider(
              builder: builder,
              child: child,
            ),
          ),
        );
}

class HistoriesServiceProvider
    extends SubChangeNotifierProvider2<AppInfo, Settings, HistoriesService> {
  HistoriesServiceProvider({
    super.child,
    TransitionBuilder? builder,
  }) : super(
          create: (context, appInfo, settings) => HistoriesService(
            database: connectDatabase(appInfo.historyDb),
            enabled: settings.writeHistory.value,
            trimming: settings.trimHistory.value,
          ),
          builder: (context, child) => ListenableListener(
            listenable: context.watch<HistoriesService>(),
            listener: () {
              HistoriesService service = context.read<HistoriesService>();
              Settings settings = context.read<Settings>();
              settings.writeHistory.value = service.enabled;
              settings.trimHistory.value = service.trimming;
            },
            child: builder?.call(context, child) ?? child!,
          ),
        );
}

class FollowsProvider extends SubProvider<AppInfo, FollowsService> {
  FollowsProvider({
    super.child,
    TransitionBuilder? builder,
  }) : super(
          create: (context, appInfo) => FollowsService.connect(
            connectDatabase(appInfo.followDb),
          ),
          builder: (context, child) => ListenableListener(
            listenable: context.watch<HostService>(),
            listener: () {
              HostService service = context.read<HostService>();
              Settings settings = context.read<Settings>();
              settings.host.value = service.host;
              settings.customHost.value = service.customHost;
            },
            child: SubChangeNotifierProvider<FollowsService, FollowsUpdater>(
              create: (context, service) => FollowsUpdater(service: service),
              child: child,
            ),
          ),
        );
}

class DenylistProvider
    extends SubChangeNotifierProvider2<Settings, Client, DenylistService> {
  DenylistProvider({super.child, super.builder})
      : super(
          create: (context, settings, client) => DenylistService(
            items: settings.denylist.value,
            pull: () async {
              CurrentUser? user = await client.currentUser(force: true);
              if (user == null) return null;
              return user.blacklistedTags.split('\n');
            },
            push: (value) async {
              settings.denylist.value = value;
              await client.updateBlacklist(value);
            },
          ),
        );
}