import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  late LogLoader loader;

  @override
  void initState() {
    super.initState();
    loader = liveLoader();
  }

  LogLoader liveLoader() => LogLoader(
        load: () => context.read<Logs>().stream().map(
            (records) => records.map((e) => LogString.fromRecord(e)).toList()),
      );

  @override
  Widget build(BuildContext context) {
    return LogPage(
      date: loader.date,
      load: (levels) => loader.load().map(
            (records) =>
                records.where((e) => levels.contains(e.level.value)).toList(),
          ),
      onShowAll: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LogFileList(
            onSelected: (loader) {
              setState(() => this.loader = loader);
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
}

class LogLoader {
  const LogLoader({
    this.date,
    required this.load,
  });

  final DateTime? date;
  final Stream<List<LogString>> Function() load;
}

class LogFileList extends StatefulWidget {
  const LogFileList({
    super.key,
    required this.onSelected,
  });

  final ValueSetter<LogLoader> onSelected;

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
    files = Directory(context.read<AppStorage>().temporaryFiles)
        .list()
        .where((e) =>
            FileSystemEntity.isFileSync(e.path) && e.path.endsWith('.log'))
        .cast<File>()
        .map((e) => LogFileInfo.parse(e.path))
        .toList();
    setState(() {});
  }

  LogLoader liveLoader() => LogLoader(
        load: () => context.read<Logs>().stream().map(
            (records) => records.map((e) => LogString.fromRecord(e)).toList()),
      );

  Stream<List<LogString>> loadFile(String path) {
    File file = File(path);
    late StreamController<List<LogString>> controller;
    controller = StreamController(
      onListen: () async {
        controller.add(await _read(file));
        try {
          controller.addStream(
            file.watch(events: FileSystemEvent.modify).asyncMap(
                  (_) async => _read(file),
                ),
          );
        } on FileSystemException {
          controller.addStream(Stream.value(await _read(file)));
        }
      },
      onCancel: () => controller.close(),
    );
    return controller.stream;
  }

  Future<List<LogString>> _read(File file) async =>
      LogString.parse(await file.readAsString()).reversed.toList();

  @override
  Widget build(BuildContext context) {
    return TileLayout(
      tileSize: 160,
      child: FutureBuilder(
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
                            onTap: () => widget.onSelected(liveLoader()),
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
                          onSelected: (file) => widget.onSelected(
                            LogLoader(
                              date: file.date,
                              load: () => loadFile(file.path),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
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
