import 'package:e1547/domain/domain.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class UserDrawerHeader extends StatelessWidget {
  const UserDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Domain>(
      builder: (context, client, child) =>
          const DrawerHeader(child: Center(child: CurrentIdentityTile())),
    );
  }
}
