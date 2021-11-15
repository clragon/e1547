import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/cupertino.dart';
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
        Map<String, List<Post>> denied = controller.denied ?? {};

        entries.addAll(denied.entries);
        entries
            .addAll(controller.allowed.value.map((e) => MapEntry(e, <Post>[])));

        entries.sort((a, b) => a.key.compareTo(b.key));

        int count = denied.values.fold(
            0, (previousValue, element) => previousValue + element.length);

        return Column(
          children: [
            SwitchListTile(
                title: Text('Blacklist'),
                subtitle: controller.denying.value && count > 0
                    ? TweenAnimationBuilder(
                        tween: IntTween(begin: 0, end: count),
                        duration: defaultAnimationDuration,
                        builder: (context, int value, child) =>
                            Text('blocked $value posts'),
                      )
                    : null,
                secondary: Icon(Icons.block),
                value: controller.denying.value,
                onChanged: (value) => controller.denying.value = value),
            CrossFade(
              showChild:
                  denied.isNotEmpty || controller.allowed.value.isNotEmpty,
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
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ValueListenableBuilder<List<String>>(
                    valueListenable: settings.denylist,
                    builder: (context, value, child) {
                      int count = value.length;
                      if (controller.denying.value) {
                        count -= denied.keys.length;
                        count -= controller.allowed.value.length;
                      }
                      return CrossFade(
                        showChild: 0 < count,
                        child: TweenAnimationBuilder(
                          tween: IntTween(begin: 0, end: count),
                          duration: defaultAnimationDuration,
                          builder: (context, int value, child) => Text(
                            '$value inactive entries',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .color!
                                  .withOpacity(0.35),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Divider(),
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
        secondary: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 24,
          ),
          child: TweenAnimationBuilder(
            tween: IntTween(begin: 0, end: entry.value.length),
            duration: Duration(milliseconds: 200),
            builder: (context, value, child) => Text(
              value.toString(),
              style: Theme.of(context).textTheme.headline6,
              textAlign: TextAlign.center,
            ),
          ),
        ));
  }
}
