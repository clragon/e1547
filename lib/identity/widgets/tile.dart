import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';

class IdentityTile extends StatelessWidget {
  const IdentityTile({
    super.key,
    required this.identity,
    this.trailing,
    this.onTap,
  });

  final Identity identity;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(identity.id),
      title: Text(identity.username ?? 'Anonymous'),
      subtitle: Text(linkToDisplay(identity.host)),
      leading: IdentityAvatar(identity.id),
      trailing: trailing,
      onTap: onTap,
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
                    IdentityAvatar(
                      identity.id,
                      radius: 32,
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
