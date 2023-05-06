import 'dart:async';

import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

class LoginPage extends StatefulWidget {
  const LoginPage();

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController apiKeyController = TextEditingController();

  bool obscurePassword = true;
  bool authFailed = false;
  String? previousPaste;
  Timer? pasteUndoTimer;

  @override
  void dispose() {
    usernameController.dispose();
    apiKeyController.dispose();
    pasteUndoTimer?.cancel();
    super.dispose();
  }

  void saveAndTest(BuildContext context) {
    FormState form = Form.of(context);
    if (form.validate()) {
      showDialog(
        context: context,
        builder: (context) => LoginLoadingDialog(
          username: usernameController.text,
          password: apiKeyController.text,
          onDone: Navigator.of(context).maybePop,
          onError: () {
            authFailed = true;
            form.validate();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: TextFormField(
          controller: usernameController,
          autocorrect: false,
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
          inputFormatters: [FilteringTextInputFormatter.deny(' ')],
          autofillHints: const [AutofillHints.username],
          textInputAction: TextInputAction.next,
          onChanged: (value) => authFailed = false,
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
        if (previousPaste != null) {
          return IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo previous paste',
            onPressed: () => setState(() {
              apiKeyController.text = previousPaste!;
              previousPaste = null;
            }),
          );
        } else {
          return IconButton(
            icon: const Icon(Icons.content_paste),
            tooltip: 'Paste',
            onPressed: () async {
              ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
              ClipboardData? data = await Clipboard.getData('text/plain');
              if (data == null || data.text!.trim().isEmpty) {
                messenger.showSnackBar(
                    const SnackBar(content: Text('Clipboard is empty')));
                return;
              }

              setState(() {
                previousPaste = apiKeyController.text;
                apiKeyController.text = data.text!;
              });

              pasteUndoTimer = Timer(const Duration(seconds: 10), () {
                setState(() {
                  previousPaste = null;
                });
              });
            },
          );
        }
      }

      String apiKeyExample = '1ca1d165e973d7f8d35b7deb7a2ae54c';

      Widget inputField() {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: TextFormField(
            autocorrect: false,
            controller: apiKeyController,
            decoration: InputDecoration(
              labelText: 'API Key',
              helperText: 'e.g. $apiKeyExample',
              border: const OutlineInputBorder(),
              suffixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    pasteButton(),
                    IconButton(
                      icon: Icon(obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => obscurePassword = !obscurePassword),
                    ),
                  ],
                ),
              ),
            ),
            obscureText: obscurePassword,
            inputFormatters: [FilteringTextInputFormatter.deny(' ')],
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            onChanged: (value) => authFailed = false,
            validator: (value) {
              if (authFailed) {
                return 'Failed to login. Please check API key.\n'
                    'e.g. $apiKeyExample';
              }

              if (value!.isEmpty) {
                return 'You must provide an API key.\n'
                    'e.g. $apiKeyExample';
              }

              if (!RegExp(r'^[A-z\d]{24,32}$').hasMatch(value)) {
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

    Widget form() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 32, right: 32, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                DimSubtree(
                  child: IconButton(
                    icon: const Icon(Icons.launch),
                    onPressed: () {
                      if (usernameController.text.isNotEmpty) {
                        launch(context.read<Client>().withHost(
                            '/users/${usernameController.text}/api_key'));
                      } else {
                        launch(context.read<Client>().withHost('/session/new'));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          usernameField(),
          apiKeyField(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                TextButton(
                  onPressed: () =>
                      launch(context.read<Client>().withHost('/users/new')),
                  child: const Text('Don\'t have an account? Sign up here'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return KeyboardDismisser(
      child: Form(
        child: Scaffold(
          appBar: const DefaultAppBar(
            leading: CloseButton(),
            elevation: 0,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 1100) {
                return LimitedWidthLayout.builder(
                  builder: (context) => ListView(
                    padding: LimitedWidthLayout.of(context)
                        .padding
                        .add(const EdgeInsets.all(16)),
                    children: [
                      const SizedBox(
                        height: 300,
                        child: Center(
                          child: AppIcon(
                            radius: 64,
                          ),
                        ),
                      ),
                      form(),
                    ],
                  ),
                );
              } else {
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppIcon(radius: 64),
                          const SizedBox(height: 32),
                          Text(
                            context.read<AppInfo>().appName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 700,
                      child: Center(
                        child: LimitedWidthLayout.builder(
                          builder: (context) => SingleChildScrollView(
                            padding: LimitedWidthLayout.of(context)
                                .padding
                                .add(const EdgeInsets.all(16)),
                            child: form(),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          floatingActionButton: Builder(
            builder: (context) => FloatingActionButton(
              child: const Icon(Icons.check),
              onPressed: () => saveAndTest(context),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginLoadingDialog extends StatefulWidget {
  const LoginLoadingDialog({
    required this.username,
    required this.password,
    this.onError,
    this.onDone,
  });

  final String username;
  final String password;
  final VoidCallback? onError;
  final VoidCallback? onDone;

  @override
  State<LoginLoadingDialog> createState() => _LoginLoadingDialogState();
}

class _LoginLoadingDialogState extends State<LoginLoadingDialog> {
  @override
  void initState() {
    super.initState();
    login();
  }

  Future<void> login() async {
    NavigatorState navigator = Navigator.of(context);
    bool valid = await context.read<ClientService>().login(
          Credentials(
            username: widget.username,
            password: widget.password,
          ),
        );
    await navigator.maybePop();
    if (valid) {
      widget.onDone?.call();
    } else {
      widget.onError?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(4),
              child: SizedBox(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Logging in as ${widget.username}'),
            )
          ],
        ),
      ),
    );
  }
}

Future<void> logout(BuildContext context) async {
  ClientService service = context.read<ClientService>();
  String? name = service.credentials?.username;
  service.logout();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 1),
      content: Text('Forgot login details ${name != null ? 'for $name' : ''}'),
    ),
  );
}

Future<void> guardWithLogin({
  required BuildContext context,
  required VoidCallback callback,
  String? error,
}) async {
  if (context.read<Client>().hasLogin) {
    callback();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        content: Text(error ?? 'You must be logged in to do that!'),
      ),
    );
    Navigator.of(context).pushNamed('/login');
  }
}
