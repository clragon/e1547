import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class GridSettingsTile extends StatelessWidget {
  final GridQuilt state;
  final void Function(GridQuilt state)? onChange;

  const GridSettingsTile({required this.state, this.onChange});

  String getDescription(GridQuilt state) {
    switch (state) {
      case GridQuilt.square:
        return 'tiles are quadratic';
      case GridQuilt.vertical:
        return 'tiles expand vertically';
      default:
        return '???';
    }
  }

  IconData getIcon(GridQuilt state) {
    switch (state) {
      case GridQuilt.square:
        return Icons.view_module;
      case GridQuilt.vertical:
        return Icons.view_column;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Quilt'),
      subtitle: Text(getDescription(state)),
      leading: Icon(getIcon(state)),
      onTap: () => showDialog(
        context: context,
        builder: (context) => SimpleDialog(
          title: const Text('Grid'),
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: GridQuilt.values
                  .map(
                    (state) => ListTile(
                      trailing: Icon(getIcon(state)),
                      title: Text(getDescription(state)),
                      onTap: () {
                        onChange!(state);
                        Navigator.of(context).maybePop();
                      },
                    ),
                  )
                  .toList(),
            )
          ],
        ),
      ),
    );
  }
}
