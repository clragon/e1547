import 'dart:async';

import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController apiKeyController = TextEditingController();

  bool authFailed = false;

  bool justPasted = false;
  String? previousPaste;
  Timer? pasteUndoTimer;

  @override
  void dispose() {
    super.dispose();
    pasteUndoTimer?.cancel();
  }

  Future<void> saveAndTest(BuildContext context) async {
    FormState form = Form.of(context)!;
    if (form.validate()) {
      showDialog(
        context: context,
        builder: (context) => LoginProgressDialog(
          username: usernameController.text,
          apiKey: apiKeyController.text,
          onDone: Navigator.of(context).maybePop,
          onError: () {
            authFailed = true;
            form.validate();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 3),
                content: Text(
                  'Failed to login. '
                  'Check your network connection and login details',
                ),
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget usernameField() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: TextFormField(
          controller: usernameController,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
          maxLines: 1,
          autofillHints: [AutofillHints.username],
          onChanged: (value) {
            authFailed = false;
          },
          validator: (value) {
            if (authFailed) {
              return 'Failed to login. Please check username.';
            }

            if (value!.trim().isEmpty) {
              return 'You must provide a username.';
            }

            return null;
          },
        ),
      );
    }

    Widget apiKeyField() {
      Widget pasteButton() {
        if (justPasted) {
          return IconButton(
            icon: Icon(Icons.undo),
            tooltip: 'Undo previous paste',
            onPressed: () => setState(() {
              justPasted = false;
              apiKeyController.text = previousPaste!;
            }),
          );
        } else {
          return IconButton(
            icon: Icon(Icons.content_paste),
            tooltip: 'Paste',
            onPressed: () async {
              ClipboardData? data = await Clipboard.getData('text/plain');
              if (data == null || data.text!.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Clipboard is empty')));
                return;
              }

              setState(() {
                justPasted = true;
                previousPaste = apiKeyController.text;
                apiKeyController.text = data.text!;
              });

              pasteUndoTimer = Timer(Duration(seconds: 10), () {
                setState(() {
                  justPasted = false;
                });
              });
            },
          );
        }
      }

      String apiKeyExample = '1ca1d165e973d7f8d35b7deb7a2ae54c';

      Widget inputField() {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: TextFormField(
            autocorrect: false,
            controller: apiKeyController,
            decoration: InputDecoration(
              labelText: 'API Key',
              helperText: 'e.g. $apiKeyExample',
              border: OutlineInputBorder(),
              suffixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: pasteButton(),
              ),
            ),
            maxLines: 1,
            inputFormatters: [
              FilteringTextInputFormatter.deny(' '),
            ],
            autofillHints: [AutofillHints.password],
            onChanged: (value) {
              authFailed = false;
            },
            validator: (value) {
              if (authFailed) {
                return 'Failed to login. Please check API key.\n'
                    'e.g. $apiKeyExample';
              }

              if (value!.isEmpty) {
                return 'You must provide an API key.\n'
                    'e.g. $apiKeyExample';
              }

              if (!RegExp(r'^[A-z0-9]{24,32}$').hasMatch(value)) {
                return 'API key is a 24 or 32-character sequence of {A..z} and {0..9}\n'
                    'e.g. $apiKeyExample';
              }

              return null;
            },
          ),
        );
      }

      return inputField();
    }

    Widget loginButton() {
      return Builder(
        builder: (context) => Padding(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).colorScheme.secondary,
            ),
            child: Text(
              'LOGIN',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
            onPressed: () => saveAndTest(context),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: DefaultAppBar(
        leading: CloseButton(),
        elevation: 0,
      ),
      body: Form(
        child: LayoutBuilder(
          builder: (context, constraints) => ListView(
            padding: EdgeInsets.all(16),
            physics: BouncingScrollPhysics(),
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * 0.4,
                ),
                child: Center(
                  child: AppIcon(
                    radius: 64,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 32, right: 32, bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (usernameController.text.isNotEmpty) {
                          launch(
                              'https://${settings.host.value}/users/${usernameController.text}/api_key');
                        } else {
                          launch('https://${settings.host.value}/session/new');
                        }
                      },
                      icon: Icon(Icons.launch),
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  usernameField(),
                  apiKeyField(),
                  loginButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginProgressDialog extends StatefulWidget {
  final String? username;
  final String? apiKey;
  final VoidCallback? onError;
  final VoidCallback? onDone;

  const LoginProgressDialog({
    required this.username,
    required this.apiKey,
    this.onError,
    this.onDone,
  });

  @override
  _LoginProgressDialogState createState() => _LoginProgressDialogState();
}

class _LoginProgressDialogState extends State<LoginProgressDialog> {
  @override
  void initState() {
    super.initState();
    client.saveLogin(widget.username!, widget.apiKey!).then((value) async {
      await Navigator.of(context).maybePop();
      if (value) {
        widget.onDone?.call();
      } else {
        widget.onError?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Row(children: [
          Padding(
            padding: EdgeInsets.all(4),
            child: SizedBox(
              height: 28,
              width: 28,
              child: CircularProgressIndicator(),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text('Logging in as ${widget.username}'),
          )
        ]),
      ),
    );
  }
}

Future<void> logout(BuildContext context) async {
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

Future<void> guardWithLogin(
    {required BuildContext context,
    required VoidCallback callback,
    String? error}) async {
  if (client.hasLogin) {
    callback();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text(error ?? 'You must be logged in to do that!'),
    ));
    Navigator.pushNamed(context, '/login');
  }
}
