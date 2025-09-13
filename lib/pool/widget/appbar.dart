import 'package:e1547/domain/domain.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class PoolAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PoolAppBar({super.key, required this.id, this.actions});

  final int id;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    final poolQuery = domain.pools.useGet(id: id, vendored: true);

    return QueryBuilder(
      query: poolQuery,
      builder: (context, state) {
        String title;
        bool showInfo = false;

        if (state.data != null) {
          title = nameToPretty(state.data!.name);
          showInfo = true;
        } else if (state.isLoading) {
          title = 'Pool #$id';
        } else {
          title = 'Pool #$id';
        }

        return DefaultAppBar(
          title: Text(title),
          actions: [
            if (showInfo && state.data != null)
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () =>
                    showPoolPrompt(context: context, pool: state.data!),
              ),
            ...?actions,
          ],
        );
      },
    );
  }
}
