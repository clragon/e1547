import 'package:e1547/domain/domain.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class PoolPage extends StatefulWidget {
  const PoolPage({super.key, required this.pool});

  final Pool pool;

  @override
  State<PoolPage> createState() => _PoolPageState();
}

class _PoolPageState extends State<PoolPage> {
  bool readerMode = true;

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    return FilterControllerProvider(
      create: (_) => PostFilter(domain),
      keys: (_) => [domain],
      child: ListenableProvider(
        create: (_) => PoolPostParams()..orderByOldest = true,
        builder: (context, _) => AdaptiveScaffold(
          appBar: PoolAppBar(id: widget.pool.id),
          endDrawer: ContextDrawer(
            title: Text(tagToName(widget.pool.name)),
            children: [
              PostReaderModeSwitch(
                value: readerMode,
                onChange: (value) {
                  setState(() => readerMode = value);
                  Navigator.of(context).maybePop();
                },
              ),
              const PoolOrderSwitch(),
            ],
          ),
          body: PostPoolPageQueryBuilder(
            poolId: widget.pool.id,
            builder: (context, state, query) => PullToRefresh(
              onRefresh: query.invalidate,
              child: CustomScrollView(
                primary: true,
                slivers: [
                  SliverPadding(
                    padding: defaultActionListPadding,
                    sliver: SliverPostList(
                      displayType: readerMode
                          ? PostDisplayType.comic
                          : PostDisplayType.grid,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
