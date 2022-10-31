import 'package:async_builder/async_builder.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

Future<void> followSheet({
  required BuildContext context,
  required String tag,
}) async {
  SheetActionController? sheetController = SheetActions.of(context);
  return showDefaultSlidingBottomSheet(
    context,
        (context, sheetState) => FollowSheet(
      tag: tag,
      sheetController: sheetController,
    ),
  );
}

class FollowSheet extends StatelessWidget {
  const FollowSheet({required this.tag, this.sheetController});

  final String tag;
  final SheetActionController? sheetController;

  @override
  Widget build(BuildContext context) {
    FollowsService follows = context.watch<FollowsService>();
    Client client = context.watch<Client>();
    return SubValueBuilder<Stream<Follow?>>(
      create: (context) => follows.watchFollow(client.host, tag),
      selector: (context) => [follows, client],
      builder: (context, value) => AsyncBuilder<Follow?>(
        stream: value,
        builder: (context, follow) => DefaultSheetBody(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).maybePop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SearchPage(tags: tag),
                    ),
                  );
                },
                child: Text(follow?.name ?? tagToName(tag)),
              ),
              if (tag.split(' ').length > 1)
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          children: tag
                              .split(' ')
                              .map((tag) => TagCard(tag: tag))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                if (follow != null) {
                  follows.removeTag(client.host, tag);
                } else {
                  follows.addTag(client.host, tag);
                }
              },
              icon: CrossFade(
                showChild: follow != null,
                secondChild: const Icon(Icons.turned_in_not),
                child: const Icon(Icons.turned_in),
              ),
              tooltip: follow != null ? 'Unfollow tag' : 'Follow tag',
            ),
          ],
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CrossFade.builder(
                showChild: follow?.thumbnail != null,
                builder: (context) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 300,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: CachedNetworkImage(
                              imageUrl: follow!.thumbnail!,
                              errorWidget: defaultErrorBuilder,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              TagSearchInfo(tag: tag),
            ],
          ),
        ),
      ),
    );
  }
}
