import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/settings/widgets/grid.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

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
              const ListTileHeader(title: 'Server'),
              Consumer<ClientService>(
                builder: (context, service, child) => MouseCursorRegion(
                  behavior: HitTestBehavior.translucent,
                  onLongPress: () => setCustomHost(context),
                  child: SwitchListTile(
                    title: const Text('Host'),
                    subtitle: Text(linkToDisplay(service.host)),
                    secondary: const Icon(Icons.storage),
                    value: service.isCustomHost,
                    onChanged: (value) async {
                      if (!service.hasCustomHost) {
                        await setCustomHost(context);
                      }
                      service.useCustomHost(value);
                    },
                  ),
                ),
              ),
              Consumer<Client>(
                builder: (context, client, child) => SubFuture<CurrentUser?>(
                  create: () => client.currentUser(),
                  keys: [client],
                  builder: (context, snapshot) => CrossFade.builder(
                    duration: const Duration(milliseconds: 200),
                    showChild: client.credentials != null,
                    builder: (context) => DividerListTile(
                      title: Text(client.credentials!.username),
                      subtitle: snapshot.data?.levelString != null
                          ? Text(snapshot.data!.levelString.toLowerCase())
                          : const Text('user'),
                      leading: const IgnorePointer(
                        child: CurrentUserAvatar(),
                      ),
                      separated: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: IgnorePointer(
                          child: IconButton(
                            icon: const Icon(Icons.exit_to_app),
                            onPressed: () => logout(context),
                          ),
                        ),
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              UserLoadingPage(client.credentials!.username),
                        ),
                      ),
                      onTapSeparated: () => logout(context),
                    ),
                    secondChild: ListTile(
                      title: const Text('Login'),
                      leading: const Icon(Icons.person_add),
                      onTap: () => Navigator.pushNamed(context, '/login'),
                    ),
                  ),
                ),
              ),
              const Divider(),
              const ListTileHeader(title: 'Display'),
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
              ExpandableNotifier(
                initialExpanded: false,
                child: ExpandableTheme(
                  data: ExpandableThemeData(
                    headerAlignment: ExpandablePanelHeaderAlignment.center,
                    iconColor: Theme.of(context).iconTheme.color,
                  ),
                  child: ExpandablePanel(
                    header: const ListTile(
                      leading: Icon(Icons.grid_view),
                      title: Text('Grid'),
                      subtitle: Text('post grid settings'),
                    ),
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            onChange: (state) => settings.quilt.value = state,
                          ),
                        ),
                      ],
                    ),
                    collapsed: const SizedBox.shrink(),
                  ),
                ),
              ),
              const Divider(),
              const ListTileHeader(title: 'Listing'),
              Consumer2<HistoriesService, Client>(
                builder: (context, service, client, child) => SubStream<int>(
                  create: () => service.length(host: client.host),
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
              Consumer<DenylistService>(
                builder: (context, denylist, child) => ListTile(
                  title: const Text('Blacklist'),
                  leading: const Icon(Icons.block),
                  subtitle: denylist.items.isNotEmpty
                      ? Text(
                          '${denylist.items.join(' ').split(' ').trim().where((e) => e[0] != '-').length} tags blocked')
                      : null,
                  onTap: () => Navigator.pushNamed(context, '/blacklist'),
                ),
              ),
              Consumer2<FollowsService, Client>(
                builder: (context, service, client, child) => SubStream<int>(
                  create: () => service.length(host: client.host),
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
              const Divider(),
              const ListTileHeader(title: 'Other'),
              ListTile(
                leading: const Icon(Icons.tune),
                title: const Text('Advanced settings'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdvancedSettingsPage(),
                  ),
                ),
              ),
              if (context.watch<Logs?>() != null)
                Consumer<Logs>(
                  builder: (context, logs, child) => SubStream<List<LogRecord>>(
                    create: () => logs.stream(
                        filter: (level, type) =>
                            level.priority == logLevelCritical.priority ||
                            level.priority == LogLevel.error.priority),
                    builder: (context, snapshot) => ListTile(
                      leading: const Icon(Icons.format_list_numbered),
                      title: const Text('Logs'),
                      subtitle: (snapshot.data?.isNotEmpty ?? false)
                          ? Text('${snapshot.data!.length} errors logged')
                          : null,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => LogRecordsPage(logs: logs),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
