import 'package:e1547/domain/domain.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

typedef HistoryConnector<T> =
    HistoryRequest Function(BuildContext context, T data);

class ItemHistoryConnector<T> extends StatefulWidget {
  const ItemHistoryConnector({
    super.key,
    required this.item,
    required this.getEntry,
    required this.child,
  });

  final T item;
  final HistoryConnector<T> getEntry;
  final Widget child;

  @override
  State<ItemHistoryConnector<T>> createState() =>
      _ItemHistoryConnectorState<T>();
}

class _ItemHistoryConnectorState<T> extends State<ItemHistoryConnector<T>> {
  @override
  void initState() {
    super.initState();
    final domain = context.read<Domain>();
    final request = widget.getEntry(context, widget.item);
    domain.histories.useAdd().mutate(request);
  }

  @override
  void didUpdateWidget(covariant ItemHistoryConnector<T> oldWidget) {
    if (oldWidget.item != widget.item) {
      final domain = context.read<Domain>();
      final request = widget.getEntry(context, widget.item);
      domain.histories.useAdd().mutate(request);
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
    required this.getEntry,
    required this.controller,
    required this.child,
  });

  final T controller;
  final HistoryConnector<T> getEntry;
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
        final domain = context.read<Domain>();
        final request = widget.getEntry(context, controller);
        domain.histories.useAdd().mutate(request);
      },
      builder: (context) => widget.child,
    );
  }
}
