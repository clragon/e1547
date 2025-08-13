import 'package:collection/collection.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class FollowEditor extends StatefulWidget {
  const FollowEditor({super.key});

  @override
  State<FollowEditor> createState() => _FollowEditorState();
}

class _FollowEditorState extends State<FollowEditor> {
  final String notify = FollowType.notify.name;
  final String subscribe = FollowType.update.name;
  final String bookmark = FollowType.bookmark.name;

  late final domain = context.read<Domain>();
  late Future<List<Follow>> all = domain.follows.all();
  late Future<Map<String, String>> follows = all.then(
    (all) => {
      notify: followString(all.where((e) => e.type == FollowType.notify)),
      subscribe: followString(all.where((e) => e.type == FollowType.update)),
      bookmark: followString(all.where((e) => e.type == FollowType.bookmark)),
    },
  );

  String followString(Iterable<Follow> follows) =>
      follows.map((e) => e.tags).join('\n');

  Future<void> edit({
    List<String>? notifications,
    List<String>? subscriptions,
    List<String>? bookmarks,
  }) async {
    List<Follow> allRemoved = [];
    List<FollowRequest> allAdded = [];

    Future<void> process(List<String> updateList, FollowType type) async {
      List<Follow> follows = await all.then(
        (value) => value.where((e) => e.type == type).toList(),
      );
      List<Follow> removed = follows
          .whereNot((e) => updateList.contains(e.tags))
          .toList();
      List<String> tags = follows.map((e) => e.tags).toList();
      List<FollowRequest> added = updateList
          .whereNot((e) => tags.contains(e))
          .map((e) => FollowRequest(tags: e, type: type))
          .toList();

      allRemoved.addAll(removed);
      allAdded.addAll(added);
    }

    if (notifications != null) {
      await process(notifications, FollowType.notify);
    }
    if (subscriptions != null) {
      await process(subscriptions, FollowType.update);
    }
    if (bookmarks != null) {
      await process(bookmarks, FollowType.bookmark);
    }

    for (final follow in allRemoved) {
      await domain.follows.delete(follow.id);
    }
    for (final follow in allAdded) {
      await domain.follows.create(tags: follow.tags, type: follow.type);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget title = const Text('Edit follows');
    return FutureLoadingPage<Map<String, String>>(
      title: title,
      future: follows,
      builder: (context, value) => MultiTextEditor(
        title: title,
        content: [
          TextEditorContent(key: notify, title: 'Notify', value: value[notify]),
          TextEditorContent(
            key: subscribe,
            title: 'Subscribe',
            value: value[subscribe],
          ),
          TextEditorContent(
            key: bookmark,
            title: 'Bookmark',
            value: value[bookmark],
          ),
        ],
        onSubmitted: (value) async {
          Map<String, List<String>> contents = Map.fromEntries(
            value
                .whereNot((e) => e.value == null)
                .map(
                  (e) => MapEntry(
                    e.key,
                    e.value!.split('\n').whereNot((e) => e.isEmpty).toList(),
                  ),
                ),
          );
          await edit(
            notifications: contents[notify],
            subscriptions: contents[subscribe],
            bookmarks: contents[bookmark],
          );
          return null;
        },
        onClosed: Navigator.of(context).maybePop,
      ),
    );
  }
}
