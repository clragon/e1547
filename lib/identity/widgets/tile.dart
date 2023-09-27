import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class IdentityTile extends StatelessWidget {
  const IdentityTile({
    super.key,
    required this.identity,
    this.onTap,
    this.leading,
    this.trailing,
  });

  final Identity identity;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(linkToDisplay(identity.host)),
      subtitle: Text(identity.username ?? 'Anonymous'),
      onTap: onTap,
      leading: leading ?? const Icon(Icons.person),
      trailing: trailing,
    );
  }
}
