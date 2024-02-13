import 'dart:io';

import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/settings/widgets/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_storage/shared_storage.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(
      builder: (context, settings, child) => Scaffold(
        appBar: const DefaultAppBar(
          title: Text('Settings'),
        ),
        body: LimitedWidthLayout.builder(
          builder: (context) => ListView(
            primary: true,
            padding: defaultActionListPadding
                .add(LimitedWidthLayout.of(context).padding),
            children: [
              const ListTileHeader(title: 'Identity'),
              Consumer<IdentitiesService>(
                builder: (context, service, child) => IdentityTile(
                  identity: service.identity,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const IdentitiesPage(),
                    ),
                  ),
                  trailing: const Icon(Icons.swap_horiz),
                ),
              ),
              const Divider(),
              const ListTileHeader(title: 'User'),
              Consumer<Client>(
                builder: (context, client, child) => ValueListenableBuilder(
                  valueListenable: client.traits,
                  builder: (context, traits, child) => ListTile(
                    title: const Text('Blacklist'),
                    leading: const Icon(Icons.block),
                    subtitle: traits.denylist.isNotEmpty
                        ? Text(
                            '${traits.denylist.join(' ').split(' ').trim().where((e) => e[0] != '-').length} tags blocked')
                        : null,
                    onTap: () => Navigator.pushNamed(context, '/blacklist'),
                  ),
                ),
              ),
              Consumer2<FollowsService, Client>(
                builder: (context, service, client, child) => SubStream<int>(
                  create: () => service.length().stream,
                  keys: [service, client.host],
                  builder: (context, snapshot) => ListTile(
                    title: const Text('Follows'),
                    subtitle: snapshot.data != null && snapshot.data != 0
                        ? Text('${snapshot.data} searches followed')
                        : null,
                    leading: const Icon(Icons.person_add),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FollowEditor(),
                      ),
                    ),
                  ),
                ),
              ),
              Consumer2<HistoriesService, Client>(
                builder: (context, service, client, child) => SubStream<int>(
                  create: () => service.length(),
                  keys: [service, client.host],
                  builder: (context, snapshot) => DividerListTile(
                    title: const Text('History'),
                    subtitle: service.enabled && snapshot.data != null
                        ? Text('${snapshot.data} pages visited')
                        : null,
                    leading: const Icon(Icons.history),
                    onTap: () => Navigator.pushNamed(context, '/history'),
                    onTapSeparated: () => service.enabled = !service.enabled,
                    separated: Switch(
                      value: service.enabled,
                      onChanged: (value) => service.enabled = value,
                    ),
                  ),
                ),
              ),
              const Divider(),
              const ListTileHeader(title: 'Appearance'),
              ValueListenableBuilder<AppTheme>(
                valueListenable: settings.theme,
                builder: (context, value, child) => ListTile(
                  title: const Text('Theme'),
                  subtitle: Text(value.name),
                  leading: const Icon(Icons.brightness_6),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text('Theme'),
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: AppTheme.values
                                .map(
                                  (theme) => ListTile(
                                    title: Text(theme.name),
                                    trailing: Container(
                                      height: 28,
                                      width: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: theme.data.cardColor,
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .iconTheme
                                              .color!,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      settings.theme.value = theme;
                                      Navigator.of(context).maybePop();
                                    },
                                  ),
                                )
                                .toList(),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              Column(
                children: [
                  ValueListenableBuilder<int>(
                    valueListenable: settings.tileSize,
                    builder: (context, value, child) => ListTile(
                      title: const Text('Tile size'),
                      subtitle: Text(value.toString()),
                      leading: const Icon(Icons.crop),
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => RangeDialog(
                          title: const Text('Tile size'),
                          value: NumberRange(value),
                          initialMode: RangeDialogMode.exact,
                          enforceMax: false,
                          canChangeMode: false,
                          division: (300 / 50).round(),
                          min: 100,
                          max: 400,
                          onSubmit: (value) {
                            if (value == null || value.value <= 0) return;
                            settings.tileSize.value = value.value;
                          },
                        ),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<GridQuilt>(
                    valueListenable: settings.quilt,
                    builder: (context, value, child) => GridSettingsTile(
                      state: value,
                      onChange: (value) => settings.quilt.value = value,
                    ),
                  ),
                ],
              ),
              ValueListenableBuilder<bool>(
                valueListenable: settings.showPostInfo,
                builder: (context, value, child) => SwitchListTile(
                  title: const Text('Post info'),
                  subtitle:
                  Text(value ? 'info on post tiles' : 'image tiles only'),
                  secondary: const Icon(Icons.subtitles),
                  value: value,
                  onChanged: (value) => settings.showPostInfo.value = value,
                ),
              ),
              const Divider(),
              const ListTileHeader(title: 'Interactions'),
              if (Platform.isAndroid)
                ValueListenableBuilder<String>(
                  valueListenable: settings.downloadPath,
                  builder: (context, value, child) => ListTile(
                    title: const Text('Download location'),
                    subtitle: Text(Uri.decodeComponent(Uri.parse(value).path)),
                    leading: const Icon(Icons.folder),
                    onTap: () async {
                      Uri? result =
                          await openDocumentTree(initialUri: Uri.parse(value));
                      if (result != null) {
                        settings.downloadPath.value = result.toString();
                      }
                    },
                  ),
                ),
              ValueListenableBuilder<bool>(
                valueListenable: settings.upvoteFavs,
                builder: (context, value, child) => SwitchListTile(
                  title: const Text('Upvote favorites'),
                  subtitle:
                      Text(value ? 'upvote and favorite' : 'favorite only'),
                  secondary: const Icon(Icons.arrow_upward),
                  value: value,
                  onChanged: (value) => settings.upvoteFavs.value = value,
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: settings.muteVideos,
                builder: (context, value, child) => SwitchListTile(
                  title: const Text('Video volume'),
                  subtitle: Text(value ? 'muted' : 'with sound'),
                  secondary: Icon(value ? Icons.volume_off : Icons.volume_up),
                  value: value,
                  onChanged: (value) => settings.muteVideos.value = value,
                ),
              ),
              const Divider(),
              const ListTileHeader(title: 'Lockscreen'),
              ValueListenableBuilder<String?>(
                valueListenable: settings.appPin,
                builder: (context, value, child) => SwitchListTile(
                  title: const Text('PIN lock'),
                  subtitle:
                      Text(value != null ? 'PIN enabled' : 'PIN disabled'),
                  secondary: const Icon(Icons.pin),
                  value: value != null,
                  onChanged: (value) async {
                    if (value) {
                      String? pin = await registerPin(context);
                      if (pin != null) {
                        settings.appPin.value = pin;
                      }
                    } else {
                      settings.appPin.value = null;
                    }
                  },
                ),
              ),
              SubFuture<bool>(
                create: () => LocalAuthentication()
                    .getAvailableBiometrics()
                    .then((e) => e.isNotEmpty),
                builder: (context, snapshot) => ValueListenableBuilder<bool>(
                  valueListenable: settings.biometricAuth,
                  builder: (context, value, child) => SwitchListTile(
                    title: const Text('Biometric lock'),
                    subtitle: Text(
                        value ? 'biometrics enabled' : 'biometrics disabled'),
                    secondary: const Icon(Icons.fingerprint),
                    value: value,
                    onChanged: (snapshot.data ?? false)
                        ? (value) => settings.biometricAuth.value = value
                        : null,
                  ),
                ),
              ),
              const Divider(),
              const ListTileHeader(title: 'Development'),
              ValueListenableBuilder<bool>(
                valueListenable: settings.showBeta,
                builder: (context, value, child) => SwitchListTile(
                  title: const Text('Experimental features'),
                  subtitle:
                      Text(value ? 'preview enabled' : 'preview disabled'),
                  secondary: const Icon(Icons.auto_awesome),
                  value: value,
                  onChanged: (value) => settings.showBeta.value = value,
                ),
              ),
              if (context.watch<Logs?>() != null) ...[
                Consumer<Logs>(
                  builder: (context, logs, child) => SubStream<List<LogRecord>>(
                    create: () => logs.stream(
                        filter: (level, type) => level >= Level.SEVERE),
                    builder: (context, snapshot) => ListTile(
                      leading: const Icon(Icons.format_list_numbered),
                      title: const Text('Logs'),
                      subtitle: (snapshot.data?.isNotEmpty ?? false)
                          ? Text('${snapshot.data!.length} errors logged')
                          : null,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LogsPage(),
                        ),
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
