import 'package:e1547/client/client.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

typedef HistoryConnector<T> =
    void Function(BuildContext context, Client client, T data);

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
    Client client = context.read<Client>();
    widget.addToHistory(context, client, widget.item);
  }

  @override
  void didUpdateWidget(covariant ItemHistoryConnector<T> oldWidget) {
    if (oldWidget.item != widget.item) {
      Client client = context.read<Client>();
      widget.addToHistory(context, client, widget.item);
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
    return SubListener(
      initialize: true,
      listenable: Listenable.merge([widget.controller]),
      listener: () async {
        T? controller = widget.controller;
        if (controller == null) return;
        await controller.waitForNextPage();
        if (controller.error != null) return;
        if (!context.mounted) return;
        Client client = context.read<Client>();
        widget.addToHistory(context, client, controller);
      },
      builder: (context) => widget.child,
    );
  }
}
