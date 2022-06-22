import 'dart:io';

import 'package:e1547/interface/interface.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:talker/talker.dart';

class Logger extends InheritedWidget {
  final Talker talker;

  const Logger({required super.child, required this.talker});

  static Talker of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Logger>()!.talker;

  static Talker? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Logger>()?.talker;

  @override
  bool updateShouldNotify(covariant Logger oldWidget) =>
      oldWidget.talker != talker;
}

class LoggerPage extends StatelessWidget {
  final Talker talker;

  const LoggerPage({super.key, required this.talker});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: talker.stream,
      builder: (context, child) => Scaffold(
        appBar: const DefaultAppBar(
          title: Text('Logs'),
        ),
        body: talker.history.isNotEmpty
            ? LimitedWidthLayout.builder(
                builder: (context) => ListView.builder(
                  reverse: true,
                  padding: LimitedWidthLayout.of(context)
                      .padding
                      .add(defaultActionListPadding),
                  itemCount: talker.history.length,
                  itemBuilder: (context, index) => LoggerCard(
                    item: talker.history.reversed.toList()[index],
                  ),
                ),
              )
            : const Center(
                child: IconMessage(
                  title: Text('No log items!'),
                  icon: Icon(
                    Icons.close,
                  ),
                ),
              ),
        floatingActionButton: talker.history.isNotEmpty
            ? FloatingActionButton(
                onPressed: () async {
                  if (Platform.isAndroid || Platform.isIOS) {
                    Directory temp = await getTemporaryDirectory();
                    File log = File(join(
                        temp.path, '${DateTime.now().toIso8601String()}.log'));
                    await log.writeAsString(talker.history.text, flush: true);
                    await Share.shareFiles([log.path]);
                    await log.delete();
                  } else {
                    Clipboard.setData(
                      ClipboardData(text: talker.history.text),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        duration: Duration(seconds: 1),
                        content: Text('Copied to clipboard'),
                      ),
                    );
                  }
                },
                child: const Icon(Icons.file_download),
              )
            : null,
      ),
    );
  }
}

class LoggerCard extends StatefulWidget {
  final TalkerDataInterface item;
  final bool expanded;

  const LoggerCard({
    super.key,
    required this.item,
    this.expanded = false,
  });

  @override
  State<LoggerCard> createState() => _LoggerCardState();
}

class _LoggerCardState extends State<LoggerCard> {
  TalkerDataInterface get item => widget.item;

  late ExpandableController controller =
      ExpandableController(initialExpanded: widget.expanded);

  @override
  void didUpdateWidget(covariant LoggerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expanded != widget.expanded) {
      controller.expanded = widget.expanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      controller: controller,
      child: ScrollOnExpand(
        child: ExpandableTheme(
          data: ExpandableThemeData(
            headerAlignment: ExpandablePanelHeaderAlignment.center,
            iconColor: item.logLevel.color,
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      color: item.logLevel.color,
                    ),
                child: Stack(
                  clipBehavior: Clip.none,
                  fit: StackFit.passthrough,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(4).copyWith(bottom: 0),
                      padding: const EdgeInsets.all(10).copyWith(top: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: item.logLevel.color),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ExpandablePanel(
                                  collapsed: Text(item.logShort),
                                  expanded: Text(item.logLong),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 16,
                      top: -8,
                      child: Container(
                        color: Theme.of(context).cardColor,
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 10),
                        child: Text(item.logTitle),
                      ),
                    ),
                    if (item.logShort != item.logLong)
                      Positioned(
                        right: 16,
                        top: -10,
                        child: Material(
                          color: Theme.of(context).cardColor,
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(text: item.logMessage),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      duration: Duration(seconds: 1),
                                      content: Text('Copied to clipboard'),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.copy,
                                    size: 20,
                                    color: item.logLevel.color,
                                  ),
                                ),
                              ),
                              Builder(
                                builder: (context) => InkWell(
                                  onTap:
                                      ExpandableController.of(context)?.toggle,
                                  child: ExpandableIcon(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension Messages on TalkerDataInterface {
  String get logShort {
    switch (runtimeType) {
      case TalkerException:
        return displayException;
      case TalkerError:
        return displayError;
      case TalkerLog:
        return '${message?.substring(0, 30)}...';
      default:
        return '';
    }
  }

  String get logLong {
    switch (runtimeType) {
      case TalkerException:
        return '$displayException\n$displayStackTrace';
      case TalkerError:
        return '$displayError\n$displayStackTrace';
      case TalkerLog:
        return message ?? '';
      default:
        return '';
    }
  }

  String get logTitle {
    return '$displayTitle | ${DateFormat('HH:mm:ss.SSS').format(time)}';
  }

  String get logMessage {
    return '$logTitle\n\n$logLong';
  }
}

extension ToColor on LogLevel? {
  Color get color {
    switch (this) {
      case LogLevel.critical:
        return Colors.red[800]!;
      case LogLevel.error:
        return Colors.red[400]!;
      case LogLevel.fine:
        return Colors.teal[400]!;
      case LogLevel.warning:
        return Colors.orange[800]!;
      case LogLevel.verbose:
        return Colors.grey[400]!;
      case LogLevel.info:
        return Colors.blue[400]!;
      case LogLevel.good:
        return Colors.green[400]!;
      case LogLevel.debug:
      default:
        return Colors.grey;
    }
  }
}
