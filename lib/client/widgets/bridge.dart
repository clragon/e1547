import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class BridgeConnector extends StatelessWidget {
  const BridgeConnector({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    final client = context.watch<Client>();
    Widget child = this.child;

    if (client.hasFeature(ClientFeature.bridge)) {
      Widget inner = child;
      child = SubEffect(
        effect: () {
          client.bridge.pull(force: true);
          return null;
        },
        keys: [client],
        child: SubValueListener(
          listenable: client.traits,
          listener: (traits) => client.bridge.push(traits: traits),
          builder: (context, _) => inner,
        ),
      );
    }

    if (client.hasFeature(FollowFeature.database)) {
      Widget inner = child;
      child = SubEffect(
        effect: () {
          client.follows.sync();
          return null;
        },
        keys: [client],
        child: SubStream<List<Follow>>(
          create: () => client.follows.all().streamed,
          keys: [client],
          listener: (event) => client.follows.sync(),
          builder: (context, _) => inner,
        ),
      );
    }

    return AvailabilityCheck(
      navigatorKey: navigatorKey,
      child: child,
    );
  }
}
