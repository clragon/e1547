import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';

class UserDrawerHeader extends StatelessWidget {
  const UserDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Client>(
      builder: (context, client, child) => DrawerHeader(
        child: Center(
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  onTap: client.identity.username != null
                      ? () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserLoadingPage(client.identity.username!),
                            ),
                          )
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 72,
                          width: 72,
                          child: IgnorePointer(child: AccountAvatar()),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                linkToDisplay(client.identity.host),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                client.identity.username ?? 'Anonymous',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.swap_horiz),
                tooltip: 'Switch identity',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const IdentitiesPage(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
