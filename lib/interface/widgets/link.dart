import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

import 'package:url_launcher/url_launcher.dart' as urls;
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as tabs;

Future<void> launch(String uri) async {
  if ((Platform.isAndroid || Platform.isIOS) &&
      RegExp(r'http(s)?://(e621|e926)\.net/*').hasMatch(uri)) {
    tabs.launch(uri);
  } else {
    urls.launchUrl(Uri.parse(uri), mode: urls.LaunchMode.externalApplication);
  }
}

typedef LinkCallback = FutureOr<void> Function(Uri? url);

class LinkHandler extends StatefulWidget {
  final Widget child;
  final LinkCallback handler;
  final LinkCallback? initialHandler;

  const LinkHandler(
      {required this.child, required this.handler, this.initialHandler});

  @override
  State<LinkHandler> createState() => _LinkHandlerState();
}

class _LinkHandlerState extends State<LinkHandler> {
  late AppLinks appLinks;
  StreamSubscription? linkListener;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      appLinks = AppLinks();
      appLinks
          .getInitialAppLink()
          .then(widget.initialHandler ?? widget.handler);
      linkListener = appLinks.uriLinkStream.listen(widget.handler);
    }
  }

  @override
  void dispose() {
    linkListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
