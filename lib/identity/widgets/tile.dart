import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/user/user.dart';
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
      title: Text(identity.username ?? 'Anonymous'),
      subtitle: Text(linkToDisplay(identity.host)),
      onTap: onTap,
      leading: leading ?? const Icon(Icons.person),
      trailing: trailing,
    );
  }
}

class CurrentIdentityTile extends StatelessWidget {
  const CurrentIdentityTile({super.key});

  @override
  Widget build(BuildContext context) {
    final identity = context.watch<IdentitiesService>().identity;
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              onTap: identity.username != null
                  ? () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              UserLoadingPage(identity.username!),
                        ),
                      )
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const SizedBox(
                      height: 64,
                      width: 64,
                      child: IgnorePointer(child: AccountAvatar()),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            identity.username ?? 'Anonymous',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            linkToDisplay(identity.host),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const IdentitiesPage(),
              ),
            ),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Icon(Icons.swap_horiz),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
