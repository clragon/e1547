import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/user/user.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import 'grid.dart';

class SettingsPage extends StatefulWidget {
  @override
  State createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return LimitedWidthLayout.builder(
      builder: (context) => Scaffold(
        appBar: const DefaultAppBar(
          title: Text('Settings'),
          leading: BackButton(),
        ),
        body: ListView(
          padding: defaultActionListPadding
              .add(LimitedWidthLayout.of(context)!.padding),
          children: [
            const SettingsHeader(title: 'Server'),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onLongPress: () => setCustomHost(context),
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  settings.host,
                  settings.customHost,
                ]),
                builder: (context, child) {
                  bool useCustomHost =
                      settings.host.value == settings.customHost.value;
                  return SwitchListTile(
                    title: const Text('Host'),
                    subtitle: Text(settings.host.value),
                    secondary: const Icon(Icons.storage),
                    value: useCustomHost,
                    onChanged: (value) async {
                      if (settings.customHost.value == null) {
                        await setCustomHost(context);
                      }
                      if (settings.customHost.value != null) {
                        settings.host.value =
                            value ? settings.customHost.value! : 'e926.net';
                      }
                    },
                  );
                },
              ),
            ),
            AnimatedBuilder(
              animation: client,
              builder: (context, child) => FutureBuilder<CurrentUser?>(
                future: client.currentUser(),
                builder: (context, snapshot) => CrossFade.builder(
                  duration: const Duration(milliseconds: 200),
                  showChild: client.credentials != null,
                  builder: (context) => DividerListTile(
                    title: Text(client.credentials!.username),
                    subtitle: snapshot.data?.levelString != null
                        ? Text(snapshot.data!.levelString.toLowerCase())
                        : null,
                    leading: const CurrentUserAvatar(),
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
            const SettingsHeader(title: 'Display'),
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
                          children: appThemeMap.keys
                              .map(
                                (theme) => ListTile(
                                  title: Text(theme.name),
                                  trailing: Container(
                                    height: 28,
                                    width: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: appThemeMap[theme]!.cardColor,
                                      border: Border.all(
                                        color:
                                            Theme.of(context).iconTheme.color!,
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
                              value: value,
                              division: (300 / 50).round(),
                              min: 100,
                              max: 400,
                              onSubmit: (value) {
                                if (value == null || value <= 0) {
                                  return;
                                }
                                settings.tileSize.value = value;
                              },
                            ),
                          ),
                        ),
                      ),
                      ValueListenableBuilder<GridQuilt>(
                        valueListenable: settings.quilt,
                        builder: (context, value, child) => GridSettingsTile(
                          state: value,
                          onChange: (state) => setState(() {
                            settings.quilt.value = state;
                          }),
                        ),
                      ),
                    ],
                  ),
                  collapsed: const SizedBox.shrink(),
                ),
              ),
            ),
            const Divider(),
            const SettingsHeader(title: 'Listing'),
            AnimatedBuilder(
              animation: historyController,
              builder: (context, child) => DividerListTile(
                title: const Text('History'),
                subtitle: settings.writeHistory.value &&
                        historyController.collection.entries.isNotEmpty
                    ? Text(
                        '${historyController.collection.entries.length} pages visited')
                    : null,
                leading: const Icon(Icons.history),
                onTap: () => Navigator.pushNamed(context, '/history'),
                onTapSeparated: () =>
                    settings.writeHistory.value = !settings.writeHistory.value,
                separated: Switch(
                  value: settings.writeHistory.value,
                  onChanged: (value) => settings.writeHistory.value = value,
                ),
              ),
            ),
            AnimatedBuilder(
              animation: denylistController,
              builder: (context, child) => ListTile(
                title: const Text('Blacklist'),
                leading: const Icon(Icons.block),
                subtitle: denylistController.items.isNotEmpty
                    ? Text(
                        '${denylistController.items.join(' ').split(' ').trim().where((e) => e[0] != '-').length} tags blocked')
                    : null,
                onTap: () => Navigator.pushNamed(context, '/blacklist'),
              ),
            ),
            AnimatedBuilder(
              animation: followController,
              builder: (context, child) => ListTile(
                title: const Text('Following'),
                subtitle: followController.items.isNotEmpty
                    ? Text('${followController.items.length} searches followed')
                    : null,
                leading: const Icon(Icons.turned_in),
                onTap: () => Navigator.pushNamed(context, '/following'),
              ),
            ),
            const Divider(),
            const SettingsHeader(title: 'Other'),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Advanced settings'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AdvancedSettingsPage(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
