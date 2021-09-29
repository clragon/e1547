import 'dart:async' show Future;

import 'package:dio/dio.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/user/user.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'grid.dart';

class SettingsPage extends StatefulWidget {
  @override
  State createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Future<void> logout() async {
    String? name = settings.credentials.value?.username;
    await client.logout();

    String msg = 'Forgot login details';
    if (name != null) {
      msg = msg + ' for $name';
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text(msg),
    ));
  }

  Widget settingsHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 72, bottom: 8, top: 8, right: 16),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: BackButton(),
      ),
      body: ListView(
        padding: EdgeInsets.all(10.0),
        physics: BouncingScrollPhysics(),
        children: [
          settingsHeader('Server'),
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
          ValueListenableBuilder<Credentials?>(
            valueListenable: settings.credentials,
            builder: (context, value, child) {
              return FutureBuilder<CurrentUser?>(
                future: client.currentUser,
                builder: (context, snapshot) => SafeCrossFade(
                  duration: Duration(milliseconds: 200),
                  showChild: value != null,
                  builder: (context) => SeparatedListTile(
                    title: Text(value!.username),
                    subtitle: snapshot.data?.levelString != null
                        ? Text(snapshot.data!.levelString.toLowerCase())
                        : null,
                    leading: CurrentUserAvatar(),
                    separated: IconButton(
                      icon: Icon(Icons.exit_to_app),
                      onPressed: logout,
                    ),
                  ),
                  secondChild: ListTile(
                    title: Text('Sign in'),
                    leading: Icon(Icons.person_add),
                    onTap: () => Navigator.pushNamed(context, '/login'),
                  ),
                ),
              );
            },
          ),
          Divider(),
          settingsHeader('Display'),
          ValueListenableBuilder<AppTheme>(
            valueListenable: settings.theme,
            builder: (context, value, child) => ListTile(
              title: Text('Theme'),
              subtitle: Text(describeEnum(value)),
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
                                title: Text(describeEnum(theme)),
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
                        title: Text('Post tile size'),
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
                    ValueListenableBuilder<GridState>(
                      valueListenable: settings.stagger,
                      builder: (context, value, child) => GridSettingsTile(
                        state: value,
                        onChange: (state) => setState(() {
                          settings.stagger.value = state;
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
          settingsHeader('Listing'),
          ValueListenableBuilder<List<String>>(
            valueListenable: settings.denylist,
            builder: (context, value, child) => ListTile(
              title: Text('Blacklist'),
              leading: Icon(Icons.block),
              subtitle: value.length > 0
                  ? Text('${value.join(' ').split(' ').where(
                        (element) => element[0] != '-',
                      ).length} tags blocked')
                  : null,
              onTap: () => Navigator.pushNamed(context, '/blacklist'),
            ),
          ),
          ValueListenableBuilder<List<Follow>>(
            valueListenable: settings.follows,
            builder: (context, value, child) => ListTile(
              title: Text('Following'),
              subtitle: value.length > 0
                  ? Text('${value.length} searches followed')
                  : null,
              leading: Icon(Icons.turned_in),
              onTap: () => Navigator.pushNamed(context, '/following'),
            ),
          ),
          Divider(),
          settingsHeader('Beta'),
          ValueListenableBuilder<bool>(
            valueListenable: settings.beta,
            builder: (context, value, child) => SwitchListTile(
              title: Text('Experimental features'),
              subtitle: Text(value ? 'preview enabled' : 'preview disabled'),
              secondary: Icon(Icons.auto_awesome),
              value: value,
              onChanged: (value) => settings.beta.value = value,
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> setCustomHost(BuildContext context) async {
  bool success = false;
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  ValueNotifier<String?> error = ValueNotifier<String?>(null);
  TextEditingController controller =
      TextEditingController(text: settings.customHost.value);
  Future<bool> submit(String text) async {
    error.value = null;
    isLoading.value = true;
    String host = text.trim();
    host = host.replaceAll(RegExp(r'^http(s)?://'), '');
    host = host.replaceAll(RegExp(r'^(www.)?'), '');
    host = host.replaceAll(RegExp(r'/$'), '');
    Dio dio = Dio(BaseOptions(
      sendTimeout: 30000,
      connectTimeout: 30000,
    ));

    if (host.isEmpty) {
      success = false;
      error.value = null;
      settings.customHost.value = null;
    } else {
      await Future.delayed(Duration(seconds: 1));
      try {
        await dio.get('https://$host');
        switch (host) {
          case 'e621.net':
            settings.customHost.value = host;
            error.value = null;
            success = true;
            break;
          case 'e926.net':
            error.value = 'default host cannot be custom host';
            success = false;
            break;
          default:
            error.value = 'Host API incompatible';
            success = false;
            break;
        }
      } on DioError {
        error.value = 'Cannot reach host';
      }
    }

    isLoading.value = false;
    return error.value == null;
  }

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Custom Host'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ValueListenableBuilder(
                  valueListenable: isLoading,
                  builder: (context, bool value, child) => CrossFade(
                    showChild: value,
                    child: Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedCircularProgressIndicator(size: 16),
                    ),
                  ),
                ),
                Expanded(
                    child: ValueListenableBuilder(
                  valueListenable: error,
                  builder: (context, String? value, child) {
                    return Theme(
                      data: value != null
                          ? Theme.of(context).copyWith(
                              colorScheme: ColorScheme.fromSwatch().copyWith(
                                  secondary: Theme.of(context).errorColor))
                          : Theme.of(context),
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.url,
                        autofocus: true,
                        maxLines: 1,
                        decoration: InputDecoration(
                            labelText: 'url', border: UnderlineInputBorder()),
                        onSubmitted: (_) async {
                          if (await submit(controller.text)) {
                            Navigator.of(context).maybePop();
                          }
                        },
                      ),
                    );
                  },
                ))
              ],
            ),
            ValueListenableBuilder(
              valueListenable: error,
              builder: (context, String? value, child) {
                return CrossFade(
                  duration: Duration(milliseconds: 200),
                  showChild: value != null,
                  child: Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.error_outline,
                            size: 14,
                            color: Theme.of(context).errorColor,
                          ),
                        ),
                        Text(
                          value ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).errorColor,
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('CANCEL'),
            onPressed: Navigator.of(context).maybePop,
          ),
          TextButton(
            child: Text('OK'),
            onPressed: () async {
              if (await submit(controller.text)) {
                Navigator.of(context).maybePop();
              }
            },
          ),
        ],
      );
    },
  );
  return success;
}
