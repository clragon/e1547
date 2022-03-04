import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
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
    return Scaffold(
      appBar: DefaultAppBar(
        title: Text('Settings'),
        leading: BackButton(),
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        padding: defaultActionListPadding,
        children: [
          SettingsHeader(title: 'Server'),
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
                  title: Text('Host'),
                  subtitle: Text(settings.host.value),
                  secondary:
                      Icon(useCustomHost ? Icons.warning : Icons.security),
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
              future: client.currentUser,
              builder: (context, snapshot) => SafeCrossFade(
                duration: Duration(milliseconds: 200),
                showChild: client.credentials != null,
                builder: (context) => DividerListTile(
                  title: Text(client.credentials!.username),
                  subtitle: snapshot.data?.levelString != null
                      ? Text(snapshot.data!.levelString.toLowerCase())
                      : null,
                  leading: CurrentUserAvatar(),
                  separated: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: IgnorePointer(
                      child: IconButton(
                        icon: Icon(Icons.exit_to_app),
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
                  title: Text('Login'),
                  leading: Icon(Icons.person_add),
                  onTap: () => Navigator.pushNamed(context, '/login'),
                ),
              ),
            ),
          ),
          Divider(),
          SettingsHeader(title: 'Display'),
          ValueListenableBuilder<AppTheme>(
            valueListenable: settings.theme,
            builder: (context, value, child) => ListTile(
              title: Text('Theme'),
              subtitle: Text(value.name),
              leading: Icon(Icons.brightness_6),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: Text('Theme'),
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
                                      color: Theme.of(context).iconTheme.color!,
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
                header: ListTile(
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
                        title: Text('Tile size'),
                        subtitle: Text(value.toString()),
                        leading: Icon(Icons.crop),
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => RangeDialog(
                            title: Text('Tile size'),
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
                collapsed: SizedBox.shrink(),
              ),
            ),
          ),
          Divider(),
          SettingsHeader(title: 'Listing'),
          ValueListenableBuilder<List<String>>(
            valueListenable: settings.denylist,
            builder: (context, value, child) => ListTile(
              title: Text('Blacklist'),
              leading: Icon(Icons.block),
              subtitle: value.isNotEmpty
                  ? Text('${value.join(' ').trim().split(' ').where(
                        (element) => element.isNotEmpty && element[0] != '-',
                      ).length} tags blocked')
                  : null,
              onTap: () => Navigator.pushNamed(context, '/blacklist'),
            ),
          ),
          ValueListenableBuilder<List<Follow>>(
            valueListenable: settings.follows,
            builder: (context, value, child) => ListTile(
              title: Text('Following'),
              subtitle: value.isNotEmpty
                  ? Text('${value.length} searches followed')
                  : null,
              leading: Icon(Icons.turned_in),
              onTap: () => Navigator.pushNamed(context, '/following'),
            ),
          ),
          Divider(),
          SettingsHeader(title: 'Other'),
          ListTile(
            leading: Icon(Icons.tune),
            title: Text('Advanced settings'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AdvancedSettingsPage(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
