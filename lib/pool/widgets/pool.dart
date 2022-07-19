import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PoolPage extends StatefulWidget {
  final Pool pool;
  final bool reversed;

  const PoolPage({required this.pool, this.reversed = false});

  @override
  State<PoolPage> createState() => _PoolPageState();
}

class _PoolPageState extends State<PoolPage> {
  late bool reversePool = widget.reversed;

  @override
  Widget build(BuildContext context) {
    return PostsProvider(
      provider: (tags, page, force) => context.read<Client>().poolPosts(
            widget.pool.id,
            page,
            reverse: reversePool,
            force: force,
          ),
      canSearch: false,
      child: Consumer<PostsController>(
        builder: (context, controller, child) => ListenableListener(
          listener: () async {
            await controller.waitForFirstPage();
            context
                .read<HistoriesService>()
                .addPool(widget.pool, posts: controller.itemList);
          },
          listenable: controller.search,
          child: PostsPage(
            controller: controller,
            appBar: DefaultAppBar(
              title: Text(tagToTitle(widget.pool.name)),
              leading: const BackButton(),
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Info',
                  onPressed: () => poolSheet(context, widget.pool),
                ),
                const ContextDrawerButton(),
              ],
            ),
            drawerActions: [
              PoolOrderSwitch(
                reversePool: reversePool,
                onChange: (value) {
                  setState(() {
                    reversePool = value;
                  });
                  controller.refresh();
                  Navigator.of(context).maybePop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PoolOrderSwitch extends StatelessWidget {
  final bool reversePool;
  final void Function(bool value) onChange;
  const PoolOrderSwitch({required this.reversePool, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: const Icon(Icons.sort),
      title: const Text('Pool order'),
      subtitle: Text(reversePool ? 'newest first' : 'oldest first'),
      value: reversePool,
      onChanged: onChange,
    );
  }
}
