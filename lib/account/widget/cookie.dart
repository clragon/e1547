import 'dart:io';

import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:webview_cookie_manager_plus/webview_cookie_manager_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
    ..setBackgroundColor(Theme.of(context).colorScheme.surface)
    ..loadRequest(Uri.https(context.read<Client>().host));

  Future<void> setCookies(BuildContext context) async {
    IdentityService service = context.read<IdentityService>();
    WebviewCookieManager cookieManager = WebviewCookieManager();
    List<Cookie> cookies = await cookieManager.getCookies(
      service.identity.host,
    );
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
    service.replace(service.identity.copyWith(headers: headers));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const CloseButton(), title: widget.title),
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
