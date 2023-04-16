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
    Talker talker = context.read<Talker>();
    try {
      await client.availability();
    } on ClientException catch (e, stacktrace) {
      if (CancelToken.isCancel(e)) {
        return;
      }
      int? statusCode = e.response?.statusCode;
      if (statusCode == null) return;
      switch (statusCode) {
        case HttpStatus.serviceUnavailable:
          controller.navigator!.push(
            MaterialPageRoute(
              builder: (context) =>
                  const HostUnvailablePage(offerResolve: true),
            ),
          );
          return;
        case HttpStatus.forbidden:
          // This could potentially logout the user.
          // However, it might be returned during Cloudflare API blockages.
          // Logout the user, and if theyre already logged out, trigger Resolver?
          return;
      }
      if (500 <= statusCode && statusCode < 600) {
        controller.navigator!.push(
          MaterialPageRoute(
            builder: (context) => const HostUnvailablePage(),
          ),
        );
      }
      talker.handle(e, stacktrace);
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

class HostUnvailablePage extends StatelessWidget {
  const HostUnvailablePage({super.key, this.offerResolve = false});

  final bool offerResolve;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              if (offerResolve && (Platform.isAndroid || Platform.isIOS)) ...[
                const Text(
                  'Please resolve the issue in the following browser window. '
                  '\n\nCloudflare captcha cookies will be saved. ',
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const CookieCapturePage(),
                    ),
                  ),
                  child: const Text('Resolve'),
                ),
              ] else
                DimSubtree(
                  child: Text(
                    '\nPlease wait for ${context.watch<Client>().host} to resolve the situation on their end.',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CookieCapturePage extends StatefulWidget {
  const CookieCapturePage({super.key, this.title});

  final Widget? title;

  @override
  State<CookieCapturePage> createState() => _CookieCapturePageState();
}

class _CookieCapturePageState extends State<CookieCapturePage> {
  late final WebViewController controller = WebViewController()
    ..setUserAgent(context.read<Client>().userAgent)
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(Theme.of(context).colorScheme.background)
    ..loadRequest(Uri.https(context.read<Client>().host));

  Future<void> setCookies(BuildContext context) async {
    CookiesService cookiesService = context.read<CookiesService>();
    ClientService clientService = context.read<ClientService>();
    await cookiesService.load(Uri.https(clientService.host).toString());
    clientService.cookies = cookiesService.cookies;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: widget.title,
      ),
      body: WebViewWidget(controller: controller),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.check),
        onPressed: () async {
          setCookies(context);
          Navigator.of(context).maybePop();
        },
      ),
    );
  }
}
