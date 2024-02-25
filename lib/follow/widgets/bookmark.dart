import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_sub/flutter_sub.dart';

class FollowsBookmarkPage extends StatelessWidget {
  const FollowsBookmarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RouterDrawerEntry<FollowsBookmarkPage>(
      child: Consumer<FollowsService>(
        builder: (context, service, child) => SubEffect(
          effect: () {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => context.read<FollowsUpdater>().update(
                    client: context.read<Client>(),
                  ),
            );
            return null;
          },
          keys: const [],
          child: SubStream<List<Follow>>(
            create: () => service.all(
              types: [FollowType.bookmark],
            ).stream,
            keys: [service],
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
                            value,
                            type: FollowType.bookmark,
                          );
                        }
                      },
                    ),
                    body: TileLayout(
                      child: LoadingPage(
                        onEmpty: const IconMessage(
                          title: Text('No bookmarks'),
                          icon: Icon(Icons.clear),
                        ),
                        onError: const IconMessage(
                          title: Text('Failed to load bookmarks'),
                          icon: Icon(Icons.warning_amber),
                        ),
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
