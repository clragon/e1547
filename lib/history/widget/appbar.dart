import 'package:e1547/domain/domain.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class HistoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HistoryAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final params = context.watch<HistoryParams>();

    return HistorySelectionAppBar(
      child: DefaultAppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('History'),
            CrossFade.builder(
              showChild: params.date != null,
              builder: (context) => Text(
                DateFormatting.named(params.date!),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).textTheme.bodySmall!.color,
                ),
              ),
            ),
          ],
        ),
        actions: const [ContextDrawerButton()],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class HistorySelectionAppBar extends StatelessWidget with AppBarBuilderWidget {
  const HistorySelectionAppBar({super.key, required this.child});

  @override
  final PreferredSizeWidget child;

  @override
  Widget build(BuildContext context) {
    return SelectionAppBar<History>(
      child: child,
      titleBuilder: (context, data) => data.selections.length == 1
          ? Text(data.selections.first.getName(context))
          : Text('${data.selections.length} entries'),
      actionBuilder: (context, data) => [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            final domain = context.read<Domain>();
            final removeMutation = domain.histories.useRemove();
            data.onChanged({});
            await removeMutation.mutate(
              data.selections.map((e) => e.id).toList(),
            );
          },
        ),
      ],
    );
  }
}
