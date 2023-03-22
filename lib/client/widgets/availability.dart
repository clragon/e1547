import 'dart:io';

import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';
import 'package:talker/talker.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ClientAvailabilityCheck extends StatelessWidget {
  const ClientAvailabilityCheck({super.key, required this.child});

  final Widget child;

  Future<void> check(BuildContext context) async {
    RouterDrawerController controller = context.read<RouterDrawerController>();
    Client client = context.read<Client>();
    try {
      await client.availability();
    } on ClientException catch (e) {
      if (CancelToken.isCancel(e)) {
        return;
      }
      switch (e.response?.statusCode) {
        case HttpStatus.serviceUnavailable:
          controller.navigator!.push(
            MaterialPageRoute(
              builder: (context) => const ClientAvailabilityResolver(),
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
  Widget build(BuildContext context) => SubEffect(
        effect: () {
          check(context);
          return null;
        },
        keys: [context.watch<Client>()],
        child: child,
      );
}

class ClientAvailabilityResolver extends StatefulWidget {
  const ClientAvailabilityResolver({super.key});

  @override
  State<ClientAvailabilityResolver> createState() =>
      _ClientAvailabilityResolverState();
}

class _ClientAvailabilityResolverState
    extends State<ClientAvailabilityResolver> {
  late final WebViewController controller = WebViewController()
    ..setUserAgent(context.read<Client>().userAgent)
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(Theme.of(context).colorScheme.background)
    ..loadRequest(Uri.https(context.read<Client>().host));

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
                  'It appears that ${context.watch<Client>().host} is not available!',
                ),
                const SizedBox(height: 16),
                if (Platform.isAndroid || Platform.isIOS) ...[
                  const Text(
                    'If possible, please resolve the situation in the following browser window. '
                    '\n\nCloudflare cookies will be saved to resolve Cloudflare issues. ',
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => setState(() => read = true),
                    child: const Text('Resolve'),
                  ),
                ] else
                  DimSubtree(
                    child: Text(
                      'Only Android and iOS devices are supported for resolving captchas in browser windows.'
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
        body: WebViewWidget(controller: controller),
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
