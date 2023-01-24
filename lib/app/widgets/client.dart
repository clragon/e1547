import 'dart:io';

import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:talker/talker.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<CookiesService> initializeCookiesService(AppInfo appInfo) async {
  final service = CookiesService();
  await service.loadAll(
    {appInfo.defaultHost, ...appInfo.allowedHosts}
        .map((e) => Uri.https(e).toString())
        .toList(),
  );
  return service;
}

class ClientFailureResolver extends StatefulWidget {
  const ClientFailureResolver({super.key, required this.child});

  final Widget child;

  @override
  State<ClientFailureResolver> createState() => _ClientFailureResolverState();
}

class _ClientFailureResolverState extends State<ClientFailureResolver> {
  Client? _client;
  ClientService? _hostService;
  CancelToken _cancelToken = CancelToken();

  Future<void> check() async {
    RouterDrawerController controller = context.read<RouterDrawerController>();
    try {
      await _client!.currentUser(cancelToken: _cancelToken);
    } on ClientException catch (e) {
      if (CancelToken.isCancel(e)) {
        return;
      }
      switch (e.response?.statusCode) {
        case HttpStatus.serviceUnavailable:
          controller.navigator!.push(
            MaterialPageRoute(
              builder: (context) => const CloudflareCaptchaResolver(),
            ),
          );
          break;
        case HttpStatus.forbidden:
          break;
      }
      context.read<Talker>().handle(e);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bool changed = false;
    ClientService hostService = context.watch<ClientService>();
    if (_hostService != hostService) {
      _hostService = hostService;
      _client = null;
      changed = true;
    }
    Client client = context.watch<Client>();
    if (_client != client) {
      _client = client;
      changed = true;
    }
    if (changed) {
      _cancelToken.cancel();
      _cancelToken = CancelToken();
      check();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class CloudflareCaptchaResolver extends StatefulWidget {
  const CloudflareCaptchaResolver({super.key});

  @override
  State<CloudflareCaptchaResolver> createState() =>
      _CloudflareCaptchaResolverState();
}

class _CloudflareCaptchaResolverState extends State<CloudflareCaptchaResolver> {
  bool read = false;

  Future<void> setCookies(BuildContext context) async {
    CookiesService cookiesService = context.read<CookiesService>();
    ClientService clientService = context.read<ClientService>();
    await cookiesService.load(Uri.https(clientService.host).toString());
    clientService.cookies = cookiesService.cookies;
  }

  @override
  Widget build(BuildContext context) {
    return CrossFade(
      showChild: read,
      secondChild: Scaffold(
        appBar: AppBar(
          leading: const CloseButton(),
          title: const Text('Host unavailable'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 60),
                const SizedBox(height: 8),
                Text(
                  'Host unavailable',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                Text(
                  'It appears that ${context.watch<Client>().host} is either not available, or Cloudflare has blocked your access.',
                ),
                const SizedBox(height: 16),
                if (Platform.isAndroid || Platform.isIOS) ...[
                  const Text(
                    'Please resolve the situation in the following browser window. '
                    '\n\nCloudflare cookies will be retrieved when you are done to restore your access.',
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => setState(() => read = true),
                    child: const Text('Resolve'),
                  ),
                ] else
                  DimSubtree(
                    child: Text(
                      'Only Android and iOS devices are supported for resolving the Cloudflare captcha.'
                      '\nPlease wait for ${context.watch<Client>().host} to resolve the situation on their end.',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: const CloseButton(),
          title: const Text('Resolve host issue'),
        ),
        body: WebView(
          userAgent: context.watch<Client>().userAgent,
          initialUrl: Uri.https(context.read<Client>().host).toString(),
          javascriptMode: JavascriptMode.unrestricted,
          backgroundColor: Theme.of(context).colorScheme.background,
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.check),
          onPressed: () async {
            setCookies(context);
            Navigator.of(context).maybePop();
          },
        ),
      ),
    );
  }
}
