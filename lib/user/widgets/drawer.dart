import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserDrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Client>(
      builder: (context, client, child) => DrawerHeader(
        child: GestureDetector(
          onTap: client.credentials != null
              ? () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          UserLoadingPage(client.credentials!.username),
                    ),
                  )
              : null,
          child: Row(
            children: [
              const SizedBox(
                height: 72,
                width: 72,
                child: CurrentUserAvatar(
                  enabled: true,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CrossFade.builder(
                    showChild: client.credentials?.username != null,
                    builder: (context) => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            client.credentials!.username,
                            style: Theme.of(context).textTheme.headline6,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    secondChild: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: OutlinedButton(
                        child: const Text('LOGIN'),
                        onPressed: () =>
                            Navigator.popAndPushNamed(context, '/login'),
                      ),
                    ),
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
