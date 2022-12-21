import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

typedef HistoryConnector<T> = void Function(
  BuildContext context,
  HistoriesService service,
  T data,
);

class ItemHistoryConnector<T> extends StatefulWidget {
  const ItemHistoryConnector({
    super.key,
    required this.item,
    required this.addToHistory,
    required this.child,
  });

  final T item;
  final HistoryConnector<T> addToHistory;
  final Widget child;

  @override
  State<ItemHistoryConnector<T>> createState() =>
      _ItemHistoryConnectorState<T>();
}

class _ItemHistoryConnectorState<T> extends State<ItemHistoryConnector<T>> {
  @override
  void initState() {
    super.initState();
    widget.addToHistory(context, context.read<HistoriesService>(), widget.item);
  }

  @override
  void didUpdateWidget(covariant ItemHistoryConnector<T> oldWidget) {
    if (oldWidget.item != widget.item) {
      widget.addToHistory(
          context, context.read<HistoriesService>(), widget.item);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class ControllerHistoryConnector<T extends DataController?>
    extends StatefulWidget {
  const ControllerHistoryConnector({
    super.key,
    required this.addToHistory,
    required this.controller,
    required this.child,
  });

  final T controller;
  final HistoryConnector<T> addToHistory;
  final Widget child;

  @override
  State<ControllerHistoryConnector<T>> createState() =>
      _ControllerHistoryConnectorState<T>();
}

class _ControllerHistoryConnectorState<T extends DataController?>
    extends State<ControllerHistoryConnector<T>> {
  @override
  Widget build(BuildContext context) {
    return ListenableListener(
      initialize: true,
      listenable: Listenable.merge([widget.controller]),
      listener: () async {
        if (widget.controller == null) return;
        try {
          await widget.controller!.waitForFirstPage();
        } on Exception {
          // we failed to load, abort adding a history entry.
          return;
        }
        if (!mounted) return;
        widget.addToHistory(
          context,
          context.read<HistoriesService>(),
          widget.controller,
        );
      },
      child: widget.child,
    );
  }
}
