import 'dart:io';

import 'package:e1547/account/account.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

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
    try {
      await client.accounts.available();
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
