import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class DrawerDenySwitch extends StatelessWidget {
  const DrawerDenySwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final filter = context.watch<PostFilter?>();
    if (filter == null) return const SizedBox.shrink();

    Map<String, List<int>> entries = {};

    filter.postFilterEntries.forEach((postId, deniers) {
      for (final denier in deniers) {
        entries.putIfAbsent(denier, () => []);
        entries[denier]!.add(postId);
      }
    });
    entries.addAll({for (final e in filter.allowedEntries) e: []});

    entries = Map.fromEntries(
      entries.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    int count = filter.postFilterEntries.entries
        .where((entry) => !filter.allowedPosts.contains(entry.key))
        .where(
          (entry) =>
              entry.value.any((tag) => !filter.allowedEntries.contains(tag)),
        )
        .length;

    return Column(
      children: [
        SwitchListTile(
          title: const Text('Blacklist'),
          subtitle: filter.denying && count > 0
              ? TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: count),
                  duration: defaultAnimationDuration,
                  builder: (context, value, child) =>
                      Text('blocked $value posts'),
                )
              : null,
          secondary: const Icon(Icons.block),
          value: filter.denying,
          onChanged: (value) => filter.denying = value,
        ),
        CrossFade(
          showChild:
              filter.postFilterEntries.isNotEmpty ||
              filter.allowedEntries.isNotEmpty,
          child: Column(
            children: [
              const Divider(),
              ...entries.entries.map(
                (entry) => DrawerDenyTile(
                  entry: entry,
                  isAllowed: !filter.allowedEntries.contains(entry.key),
                  onChanged: (value) {
                    List<String> allowed = List.from(filter.allowedEntries);
                    if (value!) {
                      allowed.remove(entry.key);
                    } else {
                      allowed.add(entry.key);
                    }
                    filter.allowedEntries = allowed;
                  },
                ),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}

class DrawerDenyTile extends StatelessWidget {
  const DrawerDenyTile({
    super.key,
    required this.entry,
    required this.isAllowed,
    required this.onChanged,
  });

  final bool isAllowed;
  final void Function(bool? value) onChanged;
  final MapEntry<String, List<int>> entry;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: isAllowed,
      onChanged: onChanged,
      title: Row(
        children: [
          Expanded(
            child: Wrap(
              children: entry.key
                  .split(' ')
                  .where((tag) => tag.isNotEmpty)
                  .map(DenyListTagCard.new)
                  .toList(),
            ),
          ),
        ],
      ),
      secondary: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 24),
        child: TweenAnimationBuilder(
          tween: IntTween(begin: 0, end: entry.value.length),
          duration: const Duration(milliseconds: 200),
          builder: (context, value, child) => Text(
            value.toString(),
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
