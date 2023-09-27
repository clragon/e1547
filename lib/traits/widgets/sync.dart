import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class TraitsSync extends StatelessWidget {
  const TraitsSync({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SubEffect(
      effect: () {
        context.read<Client>().syncTraits();
        return null;
      },
      keys: [context.watch<Client>()],
      child: SubValueListener(
        listenable: context.watch<Client>().traits,
        listener: (traits) =>
            context.read<Client>().updateTraits(traits: traits),
        builder: (context, traits) => child,
      ),
    );
  }
}
