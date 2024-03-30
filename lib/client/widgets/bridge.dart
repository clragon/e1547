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
    return AvailabilityCheck(
      navigatorKey: navigatorKey,
      child: SubEffect(
        effect: () {
          if (client.hasFeature(ClientFeature.bridge)) {
            client.bridge.pull();
          }
          if (client.hasFeature(FollowFeature.database)) {
            client.follows.sync();
          }
          return null;
        },
        keys: [client],
        child: SubValueListener(
          listenable: client.traits,
          listener: (traits) => client.bridge.push(traits: traits),
          builder: (context, _) => SubStream<List<Follow>>(
            create: () => client.follows.all().streamed,
            keys: [client],
            listener: (event) => client.follows.sync(),
            builder: (context, _) => child,
          ),
        ),
      ),
    );
  }
}
