import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

typedef LogLoader = Stream<List<LogString>> Function(List<int> levels);

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  HeroController heroController = MaterialApp.createMaterialHeroController();
  (DateTime?, LogLoader)? entry;
  (DateTime?, LogLoader)? inactiveEntry;

  @override
  void initState() {
    super.initState();
    entry = (null, (levels) => loadLogs(levels));
  }

  Stream<List<LogString>> loadLogs(List<int> levels) {
    return context
        .read<Logs>()
        .stream(filter: (level, type) => levels.contains(level.value))
        .map((e) => e.reversed.map((e) => LogString.fromRecord(e)).toList());
  }

  Stream<List<LogString>> loadFile(String path, List<int> levels) {
    late StreamController<List<LogString>> controller;
    late Isolate isolate;
    ReceivePort port = ReceivePort();

    controller = StreamController(
      onListen: () async {
        isolate = await Isolate.spawn(
          (port) async {
            try {
              File file = File(path);
              try {
                port.send(file.readAsStringSync());
              } on FileSystemException catch (e) {
                port.send(e);
                return;
              }
              try {
                await for (final _
                    in file.watch(events: FileSystemEvent.modify)) {
                  port.send(file.readAsStringSync());
                }
              } on FileSystemException {
                // platform does not support file watching
              }
            } on Object catch (e) {
              port.send(e);
            }
          },
          port.sendPort,
        );

        port.listen(
          (data) {
            if (data is String) {
              controller.add(LogString.parse(data)
                  .where((e) => levels.contains(e.level.value))
                  .toList()
                  .reversed
                  .toList());
            } else if (data is FileSystemException) {
              controller.addError(data);
            } else {
              throw data;
            }
          },
          onDone: () => controller.close(),
        );
      },
      onCancel: () {
        port.close();
        isolate.kill();
      },
    );

    return controller.stream;
  }

  @override
  Widget build(BuildContext context) {
    NavigatorState navigator = Navigator.of(context);
    return TileLayout(
      tileSize: 160,
      child: Navigator(
        pages: [
          MaterialPage(
            child: AppBarDismissalProxy(
              child: LogFileList(
                onSelected: (file) => setState(
                  () => entry =
                      (file.date, (levels) => loadFile(file.path, levels)),
                ),
                onCurrentSelected: () => setState(
                  () => entry = (null, (levels) => loadLogs(levels)),
                ),
              ),
            ),
          ),
          if (entry != null)
            MaterialPage(
              child: PopScope(
                canPop: false,
                onPopInvoked: (didPop) {
                  if (!didPop) {
                    navigator.maybePop();
                  }
                },
                child: LogPage(
                  date: entry!.$1,
                  load: entry!.$2,
                  onShowAll: () => setState(() {
                    inactiveEntry = entry;
                    entry = null;
                  }),
                ),
              ),
            ),
        ],
        observers: [heroController],
        onPopPage: (route, result) {
          if (inactiveEntry != null) {
            setState(() {
              entry = inactiveEntry;
              inactiveEntry = null;
            });
            return false;
          }
          navigator.maybePop();
          return false;
        },
      ),
    );
  }
}

class LogFileList extends StatefulWidget {
  const LogFileList({
    super.key,
    required this.onSelected,
    this.onCurrentSelected,
  });

  final void Function(LogFileInfo file) onSelected;
  final VoidCallback? onCurrentSelected;

  @override
  State<LogFileList> createState() => _LogFileListState();
}

class _LogFileListState extends State<LogFileList> {
  late Future<List<LogFileInfo>> files;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() {
    String tempDir = context.read<AppStorage>().temporaryFiles;
    files = Isolate.run<List<LogFileInfo>>(
      () async => Directory(tempDir)
          .listSync()
          .where((e) =>
              FileSystemEntity.isFileSync(e.path) && e.path.endsWith('.log'))
          .cast<File>()
          .map((e) => LogFileInfo.parse(e.path))
          .toList(),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: files,
      builder: (context, snapshot) {
        List<LogFileInfo>? files = snapshot.data
            ?.map((e) => LogFileInfo.parse(e.path))
            .sorted((a, b) => b.date.compareTo(a.date))
            .toList();
        return SelectionLayout<LogFileInfo>(
          items: files,
          child: Scaffold(
            appBar: LogFileSelectionAppBar(
              child: const DefaultAppBar(
                title: Text('Log Files'),
              ),
              onDelete: (files) {
                for (final file in files) {
                  File(file.path).delete();
                }
                load();
              },
            ),
            body: Builder(
              builder: (context) {
                if (snapshot.hasError) {
                  return const IconMessage(
                    icon: Icon(Icons.warning_amber),
                    title: Text('Failed to load log files!'),
                  );
                }
                if (files == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (files.isEmpty) {
                  return const IconMessage(
                    icon: Icon(Icons.close),
                    title: Text('No log files available!'),
                  );
                }
                return GridView.custom(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: TileLayout.of(context).crossAxisCount,
                    childAspectRatio:
                        1 / TileLayout.of(context).tileHeightFactor,
                  ),
                  childrenDelegate: SliverChildBuilderDelegate(
                    childCount: files.length + 1,
                    (context, index) {
                      if (index == 0) {
                        return InkWell(
                          onTap: SelectionLayout.of<LogFileInfo>(context)
                                  .selections
                                  .isEmpty
                              ? widget.onCurrentSelected
                              : null,
                          child: Column(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Icon(
                                    Icons.note_add,
                                    size: 38,
                                    color: dimTextColor(context),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Current\n',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      index--;
                      return LogFileTile(
                        file: files[index],
                        onSelected: widget.onSelected,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class LogFileTile extends StatelessWidget {
  const LogFileTile({
    super.key,
    required this.file,
    this.onSelected,
  });

  final LogFileInfo file;
  final void Function(LogFileInfo file)? onSelected;

  @override
  Widget build(BuildContext context) {
    return SelectionItemOverlay<LogFileInfo>(
      item: file,
      child: InkWell(
        onTap: onSelected != null ? () => onSelected!(file) : null,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Icon(
                  file.type == 'background' ? Icons.cloud : Icons.description,
                  size: 38,
                  color: dimTextColor(context),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    formatDate(file.date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    formatTime(file.date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogPage extends StatefulWidget {
  const LogPage({
    super.key,
    required this.load,
    this.date,
    this.onShowAll,
  });

  final Stream<List<LogString>> Function(List<int> levels) load;
  final DateTime? date;
  final VoidCallback? onShowAll;

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  List<int> levels = Level.LEVELS.map((e) => e.value).toList();

  @override
  Widget build(BuildContext context) {
    return SubStream<List<LogString>>(
      create: () => widget.load(levels),
      keys: [levels],
      builder: (context, snapshot) {
        List<LogString>? logs = snapshot.data;
        return SelectionLayout<LogString>(
          items: logs,
          child: Expandables(
            child: Scaffold(
              appBar: LogSelectionAppBar(
                child: DefaultAppBar(
                  title: Text(
                      'Logs${widget.date != null ? ' - ${formatDate(widget.date!)}' : ''}'),
                  actions: [
                    if (widget.onShowAll != null)
                      IconButton(
                        icon: const Icon(Icons.folder),
                        onPressed: widget.onShowAll,
                      ),
                    const ContextDrawerButton(),
                  ],
                ),
              ),
              body: Builder(builder: (context) {
                if (logs == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (logs.isEmpty) {
                  return const Center(
                    child: IconMessage(
                      title: Text('No log items!'),
                      icon: Icon(Icons.close),
                    ),
                  );
                }
                return LimitedWidthLayout.builder(
                  builder: (context) => ListView.builder(
                    reverse: true,
                    padding: LimitedWidthLayout.of(context)
                        .padding
                        .add(defaultActionListPadding),
                    itemCount: logs.length,
                    itemBuilder: (context, index) =>
                        SelectionItemOverlay<LogString>(
                      item: logs[index],
                      padding: const EdgeInsets.all(4),
                      child: LogStringCard(
                        item: logs[index],
                      ),
                    ),
                  ),
                );
              }),
              floatingActionButton: (logs?.isNotEmpty ?? false)
                  ? FloatingActionButton(
                      onPressed: () => Share.shareAsFile(
                        context,
                        logs!.map((e) => e.toString()).join('\n'),
                        name: '${logFileDateFormat.format(DateTime.now())}.log',
                      ),
                      child: const Icon(Icons.file_download),
                    )
                  : null,
              endDrawer: LogRecordDrawer(
                levels: levels,
                onChanged: (value) => setState(() => levels = value),
              ),
            ),
          ),
        );
      },
    );
  }
}
