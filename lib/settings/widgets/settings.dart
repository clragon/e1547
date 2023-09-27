import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/identity/identity.dart';
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
                  leading: const IgnorePointer(
                    child: AccountAvatar(),
                  ),
                  trailing: const Icon(Icons.swap_horiz),
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
              Consumer<HistoriesService>(
                builder: (context, service, child) => SubStream<int>(
                  create: () => service.length(),
                  keys: [service],
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
              Consumer<FollowsService>(
                builder: (context, service, child) => SubStream<int>(
                  create: () => service.length().stream,
                  keys: [service],
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
                          builder: (context) => const LogsPage(),
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
