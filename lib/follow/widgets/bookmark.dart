import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_sub/flutter_sub.dart';

class FollowsBookmarkPage extends StatelessWidget {
  const FollowsBookmarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RouterDrawerEntry<FollowsBookmarkPage>(
      child: Consumer2<FollowsService, Client>(
        builder: (context, service, client, child) => SubEffect(
          effect: () {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => context.read<FollowsUpdater>().update(
                    client: context.read<Client>(),
                    denylist: context.read<DenylistService>().items,
                  ),
            );
            return null;
          },
          keys: const [],
          child: SubStream<List<Follow>>(
            create: () => service.all(
              host: client.host,
              types: [FollowType.bookmark],
            ).stream,
            keys: [client, service],
            builder: (context, snapshot) {
              List<Follow>? follows = snapshot.data;
              return SelectionLayout<Follow>(
                items: follows,
                child: PromptActions(
                  child: AdaptiveScaffold(
                    appBar: FollowSelectionAppBar(
                      service: service,
                      child: const DefaultAppBar(
                        title: Text('Bookmarks'),
                      ),
                    ),
                    drawer: const RouterDrawer(),
                    floatingActionButton: AddTagFloatingActionButton(
                      title: 'Add to bookmarks',
                      onSubmit: (value) {
                        value = value.trim();
                        if (value.isNotEmpty) {
                          service.addTag(
                            client.host,
                            value,
                            type: FollowType.bookmark,
                          );
                        }
                      },
                    ),
                    body: TileLayout(
                      child: LoadingPage(
                        onEmpty: const Text('No bookmarks'),
                        onError: const Text('Failed to load bookmarks'),
                        isError: snapshot.hasError,
                        isBuilt: follows != null,
                        isLoading: follows == null,
                        isEmpty: follows?.isEmpty ?? false,
                        child: (context) => AlignedGridView.count(
                          primary: true,
                          padding: defaultActionListPadding,
                          addAutomaticKeepAlives: false,
                          itemCount: follows?.length ?? 0,
                          itemBuilder: (context, index) => FollowTile(
                            follow: follows![index],
                          ),
                          crossAxisCount: TileLayout.of(context).crossAxisCount,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
