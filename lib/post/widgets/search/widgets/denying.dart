import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:e1547/tag.dart';
import 'package:flutter/material.dart';

class DrawerDenySwitch extends StatelessWidget {
  final PostController controller;

  const DrawerDenySwitch({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        List<MapEntry<String, List<Post>>> entries = [];

        entries.addAll(controller.denied.entries);
        entries
            .addAll(controller.allowed.value.map((e) => MapEntry(e, <Post>[])));

        entries.sort((a, b) => a.key.compareTo(b.key));

        int count = controller.denied.values.fold(
            0, (previousValue, element) => previousValue + element.length);

        return Column(
          children: [
            SwitchListTile(
                title: Text(
                  'Blacklist',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
                subtitle: controller.denying.value
                    ? TweenAnimationBuilder(
                        tween: IntTween(begin: 0, end: count),
                        duration: Duration(milliseconds: 200),
                        builder: (context, int value, child) {
                          return Text('blocked $value posts');
                        },
                      )
                    : null,
                secondary: Icon(Icons.block),
                value: controller.denying.value,
                onChanged: (value) => controller.denying.value = value),
            CrossFade(
              showChild: controller.denied.isNotEmpty ||
                  controller.allowed.value.isNotEmpty,
              child: Column(
                children: [
                  Divider(),
                  ...entries.map(
                    (e) => DrawerDenyTile(
                      entry: e,
                      controller: controller,
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder(
                  future: settings.denylist.value,
                  builder: (context, AsyncSnapshot<List<String>> snapshot) {
                    int? count = snapshot.data?.length;
                    if (count != null && controller.denying.value) {
                      count -= controller.denied.keys.length;
                      count -= controller.allowed.value.length;
                    }
                    return CrossFade(
                      showChild: snapshot.hasData && count! > 0,
                      child: TweenAnimationBuilder(
                        tween: IntTween(begin: 0, end: count ?? 0),
                        duration: defaultAnimationDuration,
                        builder: (context, int value, child) {
                          return Text(
                            '$value inactive entries',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .color!
                                  .withOpacity(0.35),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class DrawerDenyTile extends StatelessWidget {
  final PostController controller;
  final MapEntry<String, List<Post>> entry;

  const DrawerDenyTile({required this.entry, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: !controller.allowed.value.contains(entry.key),
      onChanged: (value) {
        if (value!) {
          controller.allowed.value.remove(entry.key);
        } else {
          controller.allowed.value.add(entry.key);
        }
        controller.allowed.value = List.from(controller.allowed.value);
      },
      title: Row(
        children: [
          Expanded(
            child: Wrap(
              direction: Axis.horizontal,
              children: entry.key
                  .split(' ')
                  .where((tag) => tag.isNotEmpty)
                  .map((tag) => DenyListTagCard(tag))
                  .toList(),
            ),
          ),
        ],
      ),
      secondary: TweenAnimationBuilder(
        tween: IntTween(begin: 0, end: entry.value.length),
        duration: Duration(milliseconds: 200),
        builder: (context, int value, child) {
          return Text(value.toString(),
              style: Theme.of(context).textTheme.headline6);
        },
      ),
    );
  }
}
