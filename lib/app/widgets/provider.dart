import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';

class HistoriesServiceProvider
    extends SubChangeNotifierProvider<Settings, HistoriesService> {
  HistoriesServiceProvider({
    String? path,
    super.child,
    TransitionBuilder? builder,
  }) : super(
          create: (context, settings) => HistoriesService(
            database: connectDatabase(path ?? 'history.sqlite'),
            enabled: settings.writeHistory.value,
            trimming: settings.trimHistory.value,
          ),
          selector: (context) => [path],
          builder: (context, child) => ListenableListener(
            listenable: context.read<HistoriesService>(),
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
