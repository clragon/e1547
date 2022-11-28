import 'dart:async';

import 'package:e1547/interface/interface.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:talker/talker.dart';

export 'package:talker/talker.dart' show TalkerDataInterface;

class LoggerPage extends StatefulWidget {
  const LoggerPage({super.key, required this.talker});

  final Talker talker;

  @override
  State<LoggerPage> createState() => _LoggerPageState();
}

class _LoggerPageState extends State<LoggerPage> {
  Future<void> export() async {
    await Share.shareFile(context, widget.talker.history.text);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.talker.stream,
      builder: (context, child) => Scaffold(
        appBar: DefaultAppBar(
          title: const Text('Logs'),
          actions: [
            if (widget.talker.history.isNotEmpty)
              PopupMenuButton<VoidCallback>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) => value(),
                itemBuilder: (context) => [
                  PopupMenuTile(
                    title: 'Export',
                    icon: Icons.share,
                    value: export,
                  ),
                  PopupMenuTile(
                    title: 'Clear',
                    icon: Icons.delete_forever,
                    value: () => setState(widget.talker.cleanHistory),
                  ),
                ],
              ),
          ],
        ),
        body: widget.talker.history.isNotEmpty
            ? LimitedWidthLayout.builder(
                builder: (context) => ListView.builder(
                  reverse: true,
                  padding: LimitedWidthLayout.of(context)
                      .padding
                      .add(defaultActionListPadding),
                  itemCount: widget.talker.history.length,
                  itemBuilder: (context, index) => LoggerCard(
                    item: widget.talker.history.reversed.toList()[index],
                  ),
                ),
              )
            : const Center(
                child: IconMessage(
                  title: Text('No log items!'),
                  icon: Icon(Icons.close),
                ),
              ),
        floatingActionButton: widget.talker.history.isNotEmpty
            ? FloatingActionButton(
                onPressed: export,
                child: const Icon(Icons.file_download),
              )
            : null,
      ),
    );
  }
}

class LoggerCard extends StatefulWidget {
  const LoggerCard({
    super.key,
    required this.item,
    this.expanded = false,
  });

  final TalkerDataInterface item;
  final bool expanded;

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
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
                            if (item.logShort != item.logLong)
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

class LoggerErrorNotifier extends StatefulWidget {
  const LoggerErrorNotifier({
    super.key,
    required this.child,
    required this.talker,
    this.onOpenLogs,
  });

  final Widget child;
  final Talker talker;
  final VoidCallback? onOpenLogs;

  @override
  State<LoggerErrorNotifier> createState() => _LoggerErrorNotifierState();
}

class _LoggerErrorNotifierState extends State<LoggerErrorNotifier> {
  late StreamSubscription<TalkerDataInterface> subscription;

  @override
  void initState() {
    super.initState();
    subscription = widget.talker.stream.listen(onMessage);
  }

  @override
  void didUpdateWidget(covariant LoggerErrorNotifier oldWidget) {
    if (oldWidget.talker != widget.talker) {
      subscription.cancel();
      subscription = widget.talker.stream.listen(onMessage);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  void onMessage(TalkerDataInterface event) {
    if (kReleaseMode) return;
    if ([LogLevel.critical, LogLevel.error].contains(event.logLevel)) {
      Color background = event.logLevel.color;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          content: Builder(
            builder: (context) {
              TextStyle style = Theme.of(context).textTheme.bodyMedium!;
              Color textColor = style.color!;
              double textLuminance = textColor.computeLuminance();
              double colorDifference =
                  background.computeLuminance() - textLuminance;
              if (colorDifference.abs() < 0.2) {
                if (textLuminance > 0.5) {
                  textColor = ThemeData(brightness: Brightness.light)
                      .textTheme
                      .titleMedium!
                      .color!;
                } else {
                  textColor = ThemeData(brightness: Brightness.dark)
                      .textTheme
                      .titleMedium!
                      .color!;
                }
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'A fatal error has occured!',
                    style: style.copyWith(
                      color: textColor,
                    ),
                  ),
                  Text(
                    event.logShort.trim(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: style.copyWith(
                      color: textColor,
                    ),
                  ),
                ],
              );
            },
          ),
          backgroundColor: background,
          behavior: SnackBarBehavior.floating,
          action: widget.onOpenLogs != null
              ? SnackBarAction(
                  label: 'LOGS',
                  onPressed: widget.onOpenLogs!,
                )
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

extension Messages on TalkerDataInterface {
  String get logShort {
    String result;
    switch (runtimeType) {
      case TalkerException:
        result = displayException;
        break;
      case TalkerError:
        result = displayError;
        break;
      case TalkerLog:
        result = (message ?? '');
        break;
      default:
        result = '';
        break;
    }
    return result.trim().ellipse(60);
  }

  String get logLong {
    String result;
    switch (runtimeType) {
      case TalkerException:
        result = '$displayException\n$displayStackTrace';
        break;
      case TalkerError:
        result = '$displayError\n$displayStackTrace';
        break;
      case TalkerLog:
        result = message ?? '';
        break;
      default:
        result = '';
        break;
    }
    return result.trim();
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
