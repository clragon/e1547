import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class IdentitiesPage extends StatelessWidget {
  const IdentitiesPage({super.key});

  Widget tile(BuildContext context, Identity identity) {
    return IdentityTile(
      identity: identity,
      onTap: () {
        context.read<IdentitiesService>().activate(identity.id);
        Navigator.of(context).maybePop();
      },
      trailing: PopupMenuButton<VoidCallback>(
        icon: const Dimmed(child: Icon(Icons.more_vert)),
        onSelected: (value) => value(),
        itemBuilder: (context) => [
          PopupMenuTile(
            title: 'Edit',
            icon: Icons.edit,
            value: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => IdentityPage(identity: identity),
              ),
            ),
          ),
          PopupMenuTile(
            title: 'Delete',
            icon: Icons.delete,
            value: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete identity?'),
                content: const Text(
                  'All your data will be permanently removed, including history and follows.',
                ),
                actions: [
                  TextButton(
                    onPressed: Navigator.of(context).maybePop,
                    child: const Text('CANCEL'),
                  ),
                  ElevatedButton(
                    child: const Text('DELETE'),
                    onPressed: () {
                      Navigator.of(context).maybePop();
                      context.read<IdentitiesService>().remove(identity);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget form(BuildContext context, List<Identity> identities) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'Identity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 20),
          for (final identity in identities) tile(context, identity),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SubStream(
      create: () => context.watch<IdentitiesService>().all().stream,
      builder: (context, snapshot) => LoadingPage(
        isLoading: snapshot.connectionState == ConnectionState.waiting,
        isError: snapshot.hasError,
        isEmpty: snapshot.data?.isEmpty ?? true,
        loadingBuilder: (context, child) => Scaffold(
          appBar: const DefaultAppBar(
            leading: CloseButton(),
            elevation: 0,
            title: Text('Identities'),
          ),
          body: child(context),
        ),
        child: (context) => LimitedWidthLayout.builder(
          builder: (context) {
            List<Identity> identities = snapshot.data!;
            return Scaffold(
              appBar: const DefaultAppBar(
                leading: CloseButton(),
                elevation: 0,
              ),
              floatingActionButton: FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const IdentityPage(),
                  ),
                ),
              ),
              body: LayoutBuilder(
                builder: (context, constraints) {
                  bool isWide = constraints.maxWidth > 1100;
                  return Column(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: isWide
                              ? CrossAxisAlignment.center
                              : CrossAxisAlignment.start,
                          children: [
                            if (isWide)
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const AppIcon(radius: 64),
                                    const SizedBox(height: 32),
                                    Text(
                                      AppInfo.instance.appName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(
                              width: isWide ? 700 : constraints.maxWidth,
                              child: LimitedWidthLayout.builder(
                                maxWidth: 520,
                                builder: (context) => Center(
                                  child: ListView(
                                    padding: LimitedWidthLayout.of(context)
                                        .padding
                                        .add(defaultActionListPadding),
                                    shrinkWrap: true,
                                    children: [
                                      if (!isWide)
                                        const SizedBox(
                                          height: 300,
                                          child: Center(
                                            child: AppIcon(
                                              radius: 64,
                                            ),
                                          ),
                                        ),
                                      form(context, identities),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
