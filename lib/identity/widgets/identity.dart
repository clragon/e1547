import 'dart:async';
import 'dart:io';

import 'package:drift/isolate.dart';
import 'package:drift/native.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

class IdentityPage extends StatefulWidget {
  const IdentityPage({
    super.key,
    this.identity,
  });

  final Identity? identity;

  @override
  State<IdentityPage> createState() => _IdentityPageState();
}

class _IdentityPageState extends State<IdentityPage> {
  late final TextEditingController hostController =
      TextEditingController(text: widget.identity?.host);
  late final TextEditingController usernameController =
      TextEditingController(text: widget.identity?.username);
  late final TextEditingController apikeyController = TextEditingController(
    text: widget.identity?.headers?[HttpHeaders.authorizationHeader] != null
        ? OmittedPasswordTextInputFormatter.passwordOmitted
        : null,
  );
  ClientType? type;
  bool foundClient = false;

  late bool withAuth =
      widget.identity == null || widget.identity!.username != null;
  String? error;

  late final Listenable allFields = Listenable.merge([
    hostController,
    usernameController,
    apikeyController,
  ]);

  @override
  void initState() {
    super.initState();
    allFields.addListener(resetErrors);
    hostController.addListener(onHostChange);
    onHostChange();
  }

  void resetErrors() => WidgetsBinding.instance
      .addPostFrameCallback((_) => setState(() => error = null));

  void onHostChange() {
    ClientType? type =
        context.read<ClientFactory>().typeFromUrl(hostController.text);
    setState(() {
      if (type != null) {
        this.type = type;
        foundClient = true;
      } else {
        this.type = null;
        foundClient = false;
      }
    });
  }

  @override
  void dispose() {
    hostController.dispose();
    usernameController.dispose();
    apikeyController.dispose();
    allFields.removeListener(resetErrors);
    super.dispose();
  }

  Future<void> saveAndTest(BuildContext context) async {
    FormState form = Form.of(context);
    if (form.validate()) {
      final navigator = Navigator.of(context);
      if (type != ClientType.e621) {
        bool agreed = await showUnknownHostDialog();
        if (!agreed) return;
        type ??= ClientType.e621;
      }

      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LoginLoadingDialog(
          identity: widget.identity,
          host: hostController.text,
          type: type!,
          username: withAuth ? usernameController.text : null,
          apikey: withAuth ? apikeyController.text : null,
          onError: (value) {
            setState(() {
              value ??= 'Check your network connection and login details';
              error = 'Failed to login. \n$value';
            });
            form.validate();
          },
          onDone: navigator.maybePop,
        ),
      );
    }
  }

  Future<bool> showUnknownHostDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Unknown host'),
        content: Text(
          'The host ${linkToDisplay(hostController.text)} is not recognized.\n'
          '${AppInfo.instance.appName} only supports hosts with the official e621 API.\n'
          'If you don\'t know what this means, please do not proceed.\n',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    Widget form() {
      String? apiKeysUrl = context.watch<ClientFactory>().apiKeysUrl(
            hostController.text,
            usernameController.text,
          );
      String? registrationUrl = context.watch<ClientFactory>().registrationUrl(
            hostController.text,
          );
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Identity',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  CrossFade(
                    showChild: apiKeysUrl != null,
                    child: Dimmed(
                      child: IconButton(
                        icon: const Icon(Icons.launch),
                        onPressed: () => launch(apiKeysUrl ?? ''),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            HostFormField(
              controller: hostController,
              readOnly: widget.identity != null,
            ),
            if (kDebugMode)
              ClientTypeFormField(
                type: type,
                enabled: !foundClient,
                onChanged: (value) {
                  setState(() => type = value);
                  resetErrors();
                },
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: CheckboxFormField(
                label: 'Authentication',
                title: withAuth ? const Text('Login') : const Text('Anonymous'),
                value: withAuth,
                onChanged: (value) => setState(() => withAuth = value!),
              ),
            ),
            AnimatedSize(
              duration: defaultAnimationDuration,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (withAuth) ...[
                    UsernameFormField(controller: usernameController),
                    ApikeyFormField(
                      controller: apikeyController,
                      canOmit: widget.identity != null,
                    ),
                    CrossFade(
                      showChild: registrationUrl != null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () => launch(registrationUrl ?? ''),
                              child: const Text(
                                'Don\'t have an account? Sign up here',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        error!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
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
              bool isWide = constraints.maxWidth > 1100;
              return Column(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: isWide
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        if (isWide)
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const AppIcon(radius: 64),
                                const SizedBox(height: 32),
                                Text(
                                  AppInfo.instance.appName,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                          ),
                        SizedBox(
                          width: isWide ? 700 : constraints.maxWidth,
                          child: LimitedWidthLayout.builder(
                            maxWidth: 520,
                            builder: (context) => Center(
                              child: ListView(
                                padding: LimitedWidthLayout.of(context)
                                    .padding
                                    .add(defaultActionListPadding),
                                shrinkWrap: true,
                                children: [
                                  if (!isWide)
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
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
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
    super.key,
    required this.identity,
    required this.host,
    required this.username,
    required this.apikey,
    required this.type,
    this.onError,
    this.onDone,
  });

  final Identity? identity;
  final String host;
  final ClientType type;
  final String? username;
  final String? apikey;
  final ValueSetter<String?>? onError;
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
    IdentitiesService service = context.read<IdentitiesService>();
    Identity? identity = widget.identity;
    String host = widget.host;
    ClientType type = widget.type;
    String? username = widget.username;
    String? apikey = widget.apikey;
    Map<String, String>? headers = Map.of(identity?.headers ?? {});
    if (username != null && apikey != null) {
      if (apikey == OmittedPasswordTextInputFormatter.passwordOmitted) {
        apikey = parseBasicAuth(headers[HttpHeaders.authorizationHeader])?.$2;
        if (apikey == null) {
          throw StateError(
            'Login failed: API key was omitted but could not be recovered',
          );
        }
      }
      headers[HttpHeaders.authorizationHeader] =
          encodeBasicAuth(username, apikey);
    } else {
      headers.remove(HttpHeaders.authorizationHeader);
    }
    try {
      if (identity != null) {
        await service.replace(
          identity.copyWith(
            host: host,
            type: type,
            username: username,
            headers: headers,
          ),
        );
      } else {
        await service.add(
          IdentityRequest(
            host: host,
            type: type,
            username: username,
            headers: headers,
          ),
        );
      }
    } on DriftRemoteException catch (e) {
      Object error = e.remoteCause;
      String? reason;
      // Duplicate username/host combination
      if (error is SqliteException && error.extendedResultCode == 2067) {
        reason = 'You already have an identity under this host and username.';
      }
      await navigator.maybePop();
      widget.onError?.call(reason);
      return;
    }
    await navigator.maybePop();
    widget.onDone?.call();
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
              child: Text(
                'Connecting to ${linkToDisplay(widget.host)} as ${widget.username ?? 'anonymous'}...',
              ),
            )
          ],
        ),
      ),
    );
  }
}

class HostFormField extends StatefulWidget {
  const HostFormField({
    super.key,
    required this.controller,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final bool readOnly;

  @override
  State<HostFormField> createState() => _HostFormFieldState();
}

class _HostFormFieldState extends State<HostFormField> {
  late final TextEditingController controller =
      TextEditingController(text: widget.controller.text);
  bool isHttps = true;

  final String http = 'http://';
  final String https = 'https://';

  @override
  void initState() {
    super.initState();
    controller.addListener(_updateController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateController();
    });
  }

  void _updateController() {
    if (controller.text.startsWith(http)) {
      setState(() => isHttps = false);
      controller.text = controller.text.replaceFirst(http, '');
    } else if (controller.text.startsWith(https)) {
      setState(() => isHttps = true);
      controller.text = controller.text.replaceFirst(https, '');
    }
    widget.controller.text = '${isHttps ? https : http}${controller.text}';
  }

  @override
  void dispose() {
    controller.removeListener(_updateController);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TextFormField(
        controller: controller,
        readOnly: widget.readOnly,
        decoration: InputDecoration(
          labelText: 'Host',
          border: const OutlineInputBorder(),
          prefixText: isHttps ? 'https://' : 'http://',
        ),
        inputFormatters: [FilteringTextInputFormatter.deny(' ')],
        autofillHints: const [AutofillHints.url],
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (value!.trim().isEmpty) {
            return 'You must provide a host URL.';
          }
          try {
            if (isHttps) {
              value = 'https://$value';
            } else {
              value = 'http://$value';
            }
            Uri.parse(value);
          } on FormatException {
            return 'Invalid host URL';
          }
          return null;
        },
      ),
    );
  }
}

class UsernameFormField extends StatelessWidget {
  const UsernameFormField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TextFormField(
        controller: controller,
        autocorrect: false,
        decoration: const InputDecoration(
          labelText: 'Username',
          border: OutlineInputBorder(),
        ),
        inputFormatters: [FilteringTextInputFormatter.deny(' ')],
        autofillHints: const [AutofillHints.username],
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (value!.trim().isEmpty) {
            return 'You must provide a username.';
          }
          return null;
        },
      ),
    );
  }
}

class ApikeyFormField extends StatefulWidget {
  const ApikeyFormField({
    super.key,
    required this.controller,
    this.canOmit = false,
  });

  final TextEditingController controller;
  final bool canOmit;

  @override
  State<ApikeyFormField> createState() => _ApikeyFormFieldState();
}

class _ApikeyFormFieldState extends State<ApikeyFormField> {
  final String apiKeyExample = '1ca1d165e973d7f8d35b7deb7a2ae54c';
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: TextFormField(
        autocorrect: false,
        controller: widget.controller,
        decoration: InputDecoration(
          labelText: 'API key',
          helperText: 'e.g. $apiKeyExample',
          border: const OutlineInputBorder(),
          suffixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: obscurePassword ? 'Show' : 'Hide',
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
        inputFormatters: [
          FilteringTextInputFormatter.deny(' '),
          if (widget.canOmit) OmittedPasswordTextInputFormatter(),
        ],
        autofillHints: const [AutofillHints.password],
        textInputAction: TextInputAction.done,
        validator: (value) {
          if (value!.isEmpty) {
            return 'You must provide an API key.\n'
                'e.g. $apiKeyExample';
          }

          if (widget.canOmit &&
              value == OmittedPasswordTextInputFormatter.passwordOmitted) {
            return null;
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
}

class OmittedPasswordTextInputFormatter extends TextInputFormatter {
  static final String passwordOmitted = '-' * 24;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (oldValue.text == passwordOmitted) {
      if (newValue.text.contains(passwordOmitted)) {
        newValue = newValue.copyWith(
          text: newValue.text.replaceAll(passwordOmitted, ''),
        );
      } else {
        newValue = newValue.copyWith(
          text: '',
        );
      }
      newValue = newValue.copyWith(
        selection: TextSelection.collapsed(offset: newValue.text.length),
      );
    }
    return newValue;
  }
}

class ClientTypeFormField extends StatelessWidget {
  const ClientTypeFormField({
    super.key,
    required this.type,
    required this.onChanged,
    this.enabled,
  });

  final ClientType? type;
  final ValueSetter<ClientType?> onChanged;
  final bool? enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: DropdownButtonFormField<ClientType>(
        value: type,
        onChanged: enabled ?? true ? onChanged : null,
        items: ClientType.values
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(e.name),
              ),
            )
            .toList(),
        decoration: const InputDecoration(
          labelText: 'Client type',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null) {
            return 'You must select a client type.';
          }
          return null;
        },
      ),
    );
  }
}
