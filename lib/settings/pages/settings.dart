import 'dart:async' show Future;
import 'dart:io' show Platform;

import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/settings.dart' show db;
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  State createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String currentHost;
  String customHost;
  String username;
  String theme;
  bool useCustomHost = false;
  bool hideGallery = false;
  bool staggered = false;
  int tileSize = 0;

  bool resetApp = false;

  void linkSetting<T>(ValueNotifier<Future<T>> setting,
      Future<void> Function(T value) assignment) async {
    Future<void> setValue() async {
      var value = await setting.value;
      await assignment(value);
      if (mounted) {
        setState(() {});
      }
    }

    setting.addListener(setValue);
    await setValue();
  }

  @override
  void initState() {
    super.initState();

    Map<ValueNotifier, Future<void> Function(dynamic value)> links = {
      db.host: (value) async {
        currentHost = value;
        useCustomHost = value == await db.customHost.value;
      },
      db.customHost: (value) async => customHost = value,
      db.credentials: (value) async => username = value?.username,
      db.theme: (value) async => theme = value,
      db.hideGallery: (value) async => hideGallery = value,
      db.tileSize: (value) async => tileSize = value,
      db.staggered: (value) async => staggered = value,
    };

    links.forEach((setting, func) {
      linkSetting(setting, func);
    });
  }

  Function() _onTapSignOut(BuildContext context) {
    return () async {
      String name = username;
      await client.logout();

      String msg = 'Forgot login details';
      if (name != null) {
        msg = msg + ' for $name';
      }

      Scaffold.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 1),
        content: Text(msg),
      ));
    };
  }

  Widget settingsHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 72, bottom: 8, top: 8, right: 16),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).accentColor,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyWidgetBuilder(BuildContext context) {
      return Container(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            settingsHeader('Posts'),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onLongPress: () => setCustomHost(context),
              child: SwitchListTile(
                title: Text('Custom host'),
                subtitle: Text(currentHost ?? ' '),
                secondary: Icon(useCustomHost ? Icons.warning : Icons.security),
                value: useCustomHost,
                onChanged: (value) async {
                  if (customHost == null) {
                    await setCustomHost(context);
                  }
                  if (customHost != null) {
                    db.host.value =
                        Future.value(value ? customHost : 'e926.net');
                  }
                },
              ),
            ),
            Platform.isAndroid
                ? SwitchListTile(
                    title: Text('Hide from gallery'),
                    subtitle: hideGallery
                        ? Text('Downloads are hidden')
                        : Text('Downloads are shown'),
                    secondary: Icon(
                        hideGallery ? Icons.image_not_supported : Icons.image),
                    value: hideGallery,
                    onChanged: (hide) {
                      db.hideGallery.value = Future.value(hide);
                      setState(() {});
                    })
                : Container(),
            Divider(),
            settingsHeader('Display'),
            ListTile(
              title: Text('Theme'),
              subtitle: Text(theme ?? ' '),
              leading: Icon(Icons.brightness_6),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: Text('Theme'),
                        children: <Widget>[
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: () {
                              List<Widget> themeList = [];
                              for (String theme in themeMap.keys) {
                                themeList.add(ListTile(
                                  title: Text(theme),
                                  trailing: Container(
                                    height: 36,
                                    width: 36,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                      color: themeMap[theme].canvasColor,
                                      border: Border.all(
                                        color:
                                            Theme.of(context).iconTheme.color,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    db.theme.value = Future.value(theme);
                                    Navigator.of(context).pop();
                                  },
                                ));
                              }
                              return themeList;
                            }(),
                          )
                        ],
                      );
                    });
              },
            ),
            ListTile(
              title: Text('Post tile size'),
              subtitle: Text(tileSize.toString()),
              leading: Icon(Icons.crop),
              onTap: () async {
                int size = await showDialog<int>(
                    context: context,
                    builder: (context) {
                      return RangeDialog(
                        title: Text('Tile size'),
                        value: tileSize,
                        division: (300 / 50).round(),
                        min: 100,
                        max: 400,
                      );
                    });
                if (size == null) {
                  return;
                }
                if (size == 0) {
                  return;
                }
                resetApp = true;
                db.tileSize.value = Future.value(size);
              },
            ),
            SwitchListTile(
                title: Text('Staggered grid'),
                subtitle: Text(staggered
                    ? 'post tiles adapt their size'
                    : 'post tiles are quadratic'),
                secondary:
                    Icon(staggered ? Icons.view_quilt : Icons.view_module),
                value: staggered,
                onChanged: (value) {
                  db.staggered.value = Future.value(value);
                  setState(() {});
                }),
            Divider(),
            settingsHeader('Listing'),
            ListTile(
              title: Text('Blacklist'),
              leading: Icon(Icons.block),
              onTap: () => Navigator.pushNamed(context, '/blacklist'),
            ),
            ListTile(
              title: Text('Following'),
              leading: Icon(Icons.turned_in),
              onTap: () => Navigator.pushNamed(context, '/following'),
            ),
            Divider(),
            settingsHeader('Account'),
            FutureBuilder(
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CrossFade(
                      duration: Duration(milliseconds: 200),
                      showChild: snapshot.data,
                      child: ListTile(
                        title: Text('Sign out'),
                        subtitle: Text(username ?? ' '),
                        leading: Icon(Icons.exit_to_app),
                        onTap: _onTapSignOut(context),
                      ),
                      secondChild: ListTile(
                        title: Text('Sign in'),
                        leading: Icon(Icons.person_add),
                        onTap: () => Navigator.pushNamed(context, '/login'),
                      ));
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Container(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(),
                        ),
                      )
                    ],
                  );
                }
              },
              future: client.hasLogin,
            ),
          ],
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (resetApp) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
          leading: BackButton(),
        ),
        body: Builder(builder: bodyWidgetBuilder),
      ),
    );
  }
}

Future<bool> setCustomHost(BuildContext context) async {
  bool success = false;
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  ValueNotifier<String> error = ValueNotifier<String>(null);
  TextEditingController controller =
      TextEditingController(text: await db.customHost.value);
  Future<bool> submit(String text) async {
    error.value = null;
    isLoading.value = true;
    String host = text.trim();
    host = host.replaceAll(RegExp(r'^http(s)?://'), '');
    host = host.replaceAll(RegExp(r'^(www.)?'), '');
    host = host.replaceAll(RegExp(r'/$'), '');
    HttpHelper http = HttpHelper();
    if (host.isEmpty) {
      success = false;
      error.value = null;
      db.customHost.value = Future.value(null);
    } else {
      await Future.delayed(Duration(seconds: 1));
      try {
        if ((await http
            .get(host, '/')
            .then((response) => response.statusCode != 200))) {
          error.value = 'Cannot reach host';
        } else {
          switch (host) {
            case 'e621.net':
              db.customHost.value = Future.value(host);
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
        }
      } catch (SocketException) {
        error.value = 'Cannot reach host';
      }
    }

    isLoading.value = false;
    return error.value == null;
  }

  await showDialog(
      context: context,
      child: AlertDialog(
        title: Text('Custom Host'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ValueListenableBuilder(
                  valueListenable: isLoading,
                  builder: (BuildContext context, value, Widget child) =>
                      CrossFade(
                          showChild: value,
                          child: Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Padding(
                              padding: EdgeInsets.all(4),
                              child: Container(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          )),
                ),
                Expanded(
                    child: ValueListenableBuilder(
                  valueListenable: error,
                  builder: (BuildContext context, value, Widget child) {
                    return Theme(
                      data: value != null
                          ? Theme.of(context).copyWith(
                              accentColor: Theme.of(context).errorColor)
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
                            Navigator.of(context).pop();
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
              builder: (BuildContext context, value, Widget child) {
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
                  secondChild: Container(),
                );
              },
            ),
          ],
        ),
        actions: [
          FlatButton(
            child: Text('CANCEL'),
            onPressed: Navigator.of(context).pop,
          ),
          FlatButton(
            child: Text('OK'),
            onPressed: () async {
              if (await submit(controller.text)) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ));
  return success;
}
