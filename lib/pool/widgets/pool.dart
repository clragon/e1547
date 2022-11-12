import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class PoolPage extends StatefulWidget {
  const PoolPage({required this.pool, this.reversed = false});

  final Pool pool;
  final bool reversed;

  @override
  State<PoolPage> createState() => _PoolPageState();
}

class _PoolPageState extends State<PoolPage> {
  late bool reversePool = widget.reversed;
  bool readerMode = false;

  @override
  Widget build(BuildContext context) {
    return PostsProvider(
      provider: (client, tags, page, force) => client.poolPosts(
        widget.pool.id,
        page,
        reverse: reversePool,
        force: force,
      ),
      canSearch: false,
      child: Consumer<PostsController>(
        builder: (context, controller, child) => ListenableListener(
          listener: () async {
            HistoriesService service = context.read<HistoriesService>();
            Client client = context.read<Client>();
            await controller.waitForFirstPage();
            await service.addPool(
              client.host,
              widget.pool,
              posts: controller.itemList,
            );
          },
          listenable: controller.search,
          child: PostsPage(
            controller: controller,
            displayType: readerMode ? PostDisplayType.comic : null,
            appBar: DefaultAppBar(
              title: Text(tagToName(widget.pool.name)),
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
              Builder(
                builder: (context) => PoolReaderSwitch(
                  readerMode: readerMode,
                  onChange: (value) {
                    setState(() => readerMode = value);
                    Scaffold.of(context).closeEndDrawer();
                  },
                ),
              ),
              Builder(
                builder: (context) => PoolOrderSwitch(
                  reversePool: reversePool,
                  onChange: (value) {
                    setState(() {
                      reversePool = value;
                    });
                    controller.refresh();
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
    required this.reversePool,
    required this.onChange,
  });

  final bool reversePool;
  final ValueChanged<bool> onChange;

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
