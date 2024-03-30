import 'dart:io';

import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AvailabilityCheck extends StatefulWidget {
  const AvailabilityCheck({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<AvailabilityCheck> createState() => _AvailabilityCheckState();
}

class _AvailabilityCheckState extends State<AvailabilityCheck> {
  final Logger logger = Logger('ClientAvailability');

  @override
  void initState() {
    super.initState();
    check(context);
  }

  Future<void> check(BuildContext context) async {
    bool? offerResolve;
    Client client = context.read<Client>();
    if (!client.hasFeature(ClientFeature.bridge)) return;
    try {
      await client.bridge.available();
      logger.info('Client is available!');
    } on ClientException catch (e, stacktrace) {
      if (CancelToken.isCancel(e)) {
        logger.fine('Client availability check cancelled!');
        return;
      }
      int? statusCode = e.response?.statusCode;
      if (statusCode == null) return;
      switch (statusCode) {
        case HttpStatus.serviceUnavailable:
          logger.warning('Client is unavailable, attempting resolve!');
          offerResolve = true;
          break;
        case HttpStatus.forbidden:
          logger.warning('Client has denied access! Failing silently...');
          // This could potentially logout the user.
          // However, it might be returned during Cloudflare API blockages.
          // Logout the user, and if theyre already logged out, trigger Resolver?
          break;
        case >= 500 && < 600:
          logger.warning('Client is unavailable, resolve not possible!');
          offerResolve = false;
          return;
        default:
          logger.severe('Availability Check failed!', e, stacktrace);
      }
    }

    if (offerResolve case final bool offerResolve) {
      widget.navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => HostUnvailablePage(offerResolve: offerResolve),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class HostUnvailablePage extends StatelessWidget {
  const HostUnvailablePage({super.key, this.offerResolve = false});

  final bool offerResolve;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TransparentAppBar(
        child: AppBar(leading: const CloseButton()),
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
                'It appears that ${linkToDisplay(context.watch<Client>().host)} is not available!',
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
                Dimmed(
                  child: Text(
                    '\nPlease wait for ${linkToDisplay(context.watch<Client>().host)} to resolve the situation on their end.',
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
    ..setUserAgent(AppInfo.instance.userAgent)
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(Theme.of(context).colorScheme.background)
    ..loadRequest(Uri.https(context.read<Client>().host));

  Future<void> setCookies(BuildContext context) async {
    IdentityService service = context.read<IdentityService>();
    WebviewCookieManager cookieManager = WebviewCookieManager();
    List<Cookie> cookies =
        await cookieManager.getCookies(service.identity.host);
    Map<String, String> headers = service.identity.headers ?? {};
    String? cookieHeader = headers['Cookie'];
    if (cookieHeader != null) {
      cookieHeader.split('; ').forEach((String cookie) {
        List<String> splitCookie = cookie.split('=');
        if (splitCookie.length == 2) {
          headers[splitCookie[0]] = splitCookie[1];
        }
      });
    }
    for (final cookie in cookies) {
      headers[cookie.name] = cookie.value;
    }
    List<String> cookieList = [];
    for (final cookie in headers.entries) {
      cookieList.add('${cookie.key}=${cookie.value}');
    }
    String newCookieHeader = cookieList.join('; ');
    headers[HttpHeaders.cookieHeader] = newCookieHeader;
    service.replace(
      service.identity.copyWith(
        headers: headers,
      ),
    );
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
