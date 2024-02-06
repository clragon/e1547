import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:e1547/app/app.dart';
import 'package:flutter/material.dart';

typedef LinkCallback = FutureOr<void> Function(Uri? url);

class AppLinkHandler extends StatefulWidget {
  const AppLinkHandler({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<AppLinkHandler> createState() => _AppLinkHandlerState();
}

class _AppLinkHandlerState extends State<AppLinkHandler> {
  late AppLinks appLinks;
  StreamSubscription<Uri>? linkListener;

  Future<void> onInitialLink(Uri? url) async {
    if (url != null) {
      VoidCallback? action = const E621LinkParser().parseOnTap(
        widget.navigatorKey.currentContext!,
        url.toString(),
      );
      if (action != null) {
        widget.navigatorKey.currentState!.popUntil((route) => false);
        action();
      } else {
        await launch(url.toString());
      }
    }
  }

  Future<void> onLink(Uri? url) async {
    if (url != null) {
      if (!const E621LinkParser().open(
        widget.navigatorKey.currentContext!,
        url.toString(),
      )) {
        await launch(url.toString());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      appLinks = AppLinks();
      appLinks.getInitialAppLink().then(onInitialLink);
      linkListener = appLinks.uriLinkStream.listen(onLink);
    }
  }

  @override
  void dispose() {
    linkListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
