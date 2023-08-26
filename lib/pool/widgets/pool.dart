import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class PoolPage extends StatefulWidget {
  const PoolPage({required this.pool, this.orderByOldest});

  final Pool pool;
  final bool? orderByOldest;

  @override
  State<PoolPage> createState() => _PoolPageState();
}

class _PoolPageState extends State<PoolPage> {
  bool readerMode = true;

  @override
  Widget build(BuildContext context) {
    return PostsProvider.builder(
      create: (context, client, denylist) => PoolController(
        client: client,
        denylist: denylist,
        id: widget.pool.id,
        orderByOldest: widget.orderByOldest ?? true,
      ),
      child: Consumer<PostsController>(
        builder: (context, controller, child) => SubListener(
          initialize: true,
          listenable: controller,
          listener: () async {
            HistoriesService service = context.read<HistoriesService>();
            Client client = context.read<Client>();
            try {
              await controller.waitForNextPage();
              await service.addPool(
                client.host,
                widget.pool,
                posts: controller.items,
              );
            } on ClientException {
              return;
            }
          },
          builder: (context) => PostsPage(
            controller: controller,
            displayType: readerMode ? PostDisplayType.comic : null,
            appBar: DefaultAppBar(
              title: Text(tagToName(widget.pool.name)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Info',
                  onPressed: () => showPoolPrompt(
                    context: context,
                    pool: widget.pool,
                  ),
                ),
                const ContextDrawerButton(),
              ],
            ),
            drawerActions: [
              Builder(
                builder: (context) => PoolReaderSwitch(
                  readerMode: readerMode,
                  onChange: (value) {
                    setState(() => readerMode = value);
                    Scaffold.of(context).closeEndDrawer();
                  },
                ),
              ),
              AnimatedBuilder(
                animation: controller,
                builder: (context, child) => PoolOrderSwitch(
                  oldestFirst: controller.orderPools,
                  onChange: (value) {
                    controller.orderPools = value;
                    Scaffold.of(context).closeEndDrawer();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PoolOrderSwitch extends StatelessWidget {
  const PoolOrderSwitch({
    required this.oldestFirst,
    required this.onChange,
  });

  final bool oldestFirst;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: const Icon(Icons.sort),
      title: const Text('Pool order'),
      subtitle: Text(oldestFirst ? 'oldest first' : 'newest first'),
      value: oldestFirst,
      onChanged: onChange,
    );
  }
}

class PoolReaderSwitch extends StatelessWidget {
  const PoolReaderSwitch({
    super.key,
    required this.readerMode,
    required this.onChange,
  });

  final bool readerMode;
  final ValueChanged<bool> onChange;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: const Icon(Icons.auto_stories),
      title: const Text('Pool reader mode'),
      subtitle: Text(readerMode ? 'large images' : 'normal grid'),
      value: readerMode,
      onChanged: onChange,
    );
  }
}
