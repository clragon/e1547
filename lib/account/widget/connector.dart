import 'package:e1547/account/account.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class AccountConnector extends StatelessWidget {
  const AccountConnector({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    return AvailabilityCheck(
      navigatorKey: navigatorKey,
      child: SubEffect(
        effect: () {
          domain.followsServer.sync();
          return null;
        },
        keys: [domain],
        child: SubStream<List<Follow>>(
          create: () => domain.follows.all().streamed,
          keys: [domain],
          listener: (event) => domain.followsServer.sync(),
          builder: (context, _) => SubEffect(
            effect: () {
              domain.accounts.pull(force: true);
              return null;
            },
            keys: [domain],
            child: SubValueListener(
              listenable: domain.traits,
              listener: (traits) => domain.accounts.push(traits: traits),
              builder: (context, _) => child,
            ),
          ),
        ),
      ),
    );
  }
}
