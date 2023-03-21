import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class PoolPage extends StatefulWidget {
  const PoolPage({required this.pool, this.oldestFirst = true});

  final Pool pool;
  final bool oldestFirst;

  @override
  State<PoolPage> createState() => _PoolPageState();
}

class _PoolPageState extends State<PoolPage> {
  late bool oldestFirst = widget.oldestFirst;
  bool readerMode = true;

  @override
  Widget build(BuildContext context) {
    return PostsProvider(
      fetch: (controller, tags, page, force) => controller.client.poolPosts(
        widget.pool.id,
        page,
        reverse: !oldestFirst,
        force: force,
        cancelToken: controller.cancelToken,
      ),
      canSearch: false,
      child: Consumer<PostsController>(
        builder: (context, controller, child) => SubListener(
          initialize: true,
          listenable: controller.search,
          listener: () async {
            HistoriesService service = context.read<HistoriesService>();
            Client client = context.read<Client>();
            try {
              await controller.waitForFirstPage();
              await service.addPool(
                client.host,
                widget.pool,
                posts: controller.itemList,
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
                  oldestFirst: oldestFirst,
                  onChange: (value) {
                    setState(() {
                      oldestFirst = value;
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
