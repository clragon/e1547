import 'dart:async' show Future;

import 'package:dio/dio.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/dtext/dtext.dart';
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
                    title: Text('Login'),
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
                    ValueListenableBuilder<bool>(
                      valueListenable: settings.beta,
                      builder: (context, value, child) => SafeCrossFade(
                        showChild: value,
                        builder: (context) => ValueListenableBuilder<bool>(
                          valueListenable: settings.postInfo,
                          builder: (context, value, child) => SwitchListTile(
                            title: Text('Post info'),
                            subtitle: Text(value ? 'shown' : 'hidden'),
                            secondary: Icon(Icons.description),
                            value: value,
                            onChanged: (value) =>
                                settings.postInfo.value = value,
                          ),
                        ),
                      ),
                    ),
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
              onChanged: (value) {
                settings.beta.value = value;
                if (!value) {
                  settings.postInfo.value = false;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> setCustomHost(BuildContext context) async {
  TextEditingController controller =
      TextEditingController(text: settings.customHost.value);

  Future<void> submit() async {
    String? error;

    String host = linkToDisplay(controller.text);

    Dio dio = Dio(BaseOptions(
      sendTimeout: 30000,
      connectTimeout: 30000,
    ));

    if (host.isEmpty) {
      settings.customHost.value = null;
    } else {
      await Future.delayed(Duration(seconds: 1));
      try {
        await dio.get('https://$host');
        switch (host) {
          case 'e621.net':
            settings.customHost.value = host;
            error = null;
            break;
          case 'e926.net':
            error = 'default host cannot be custom host';
            break;
          default:
            error = 'Host API incompatible';
            break;
        }
      } on DioError {
        error = 'Cannot reach host';
      }
    }

    if (error != null) {
      throw LoadingDialogException(message: error);
    }
  }

  await showDialog(
    context: context,
    builder: (BuildContext context) => LoadingDialog(
      submit: submit,
      title: Text('Custom Host'),
      builder: (context, submit) => TextField(
        controller: controller,
        keyboardType: TextInputType.url,
        autofocus: true,
        maxLines: 1,
        decoration: InputDecoration(labelText: 'url'),
        onSubmitted: (_) => submit(),
      ),
    ),
  );
}
