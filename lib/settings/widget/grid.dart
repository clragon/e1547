import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

extension GridQuiltDescription on GridQuilt {
  String get description {
    switch (this) {
      case GridQuilt.square:
        return 'tiles are quadratic';
      case GridQuilt.vertical:
        return 'tiles expand vertically';
    }
  }

  IconData get icon {
    switch (this) {
      case GridQuilt.square:
        return Icons.view_module;
      case GridQuilt.vertical:
        return Icons.view_column;
    }
  }
}

class GridSettingsTile extends StatelessWidget {
  const GridSettingsTile({super.key, required this.state, this.onChange});

  final GridQuilt state;
  final void Function(GridQuilt state)? onChange;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Quilt'),
      subtitle: Text(state.description),
      leading: Icon(state.icon),
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
                      trailing: Icon(state.icon),
                      title: Text(state.description),
                      onTap: () {
                        onChange!(state);
                        Navigator.of(context).maybePop();
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
