import 'package:e1547/client/client.dart';
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
        context.read<Client>().traits.pull();
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
