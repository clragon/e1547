import 'package:e1547/client/client.dart';
import 'package:e1547/follow/data/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class ClientSync extends StatelessWidget {
  const ClientSync({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SubEffect(
      effect: () {
        final client = context.read<Client>();
        if (client.hasFeature(ClientFeature.traits)) {
          client.traits.pull();
        }
        if (client.hasFeature(FollowFeature.database)) {
          client.follows.sync();
        }
        return null;
      },
      keys: [context.watch<Client>()],
      child: SubValueListener(
        listenable: context.watch<Client>().traitsState,
        listener: (traits) =>
            context.read<Client>().traits.push(traits: traits),
        builder: (context, traits) => child,
      ),
    );
  }
}
