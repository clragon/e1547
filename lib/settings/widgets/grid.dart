import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

class GridSettingsTile extends StatelessWidget {
  final GridState state;
  final void Function(GridState state) onChange;

  const GridSettingsTile({@required this.state, this.onChange});

  String getDescription(GridState state) {
    switch (state) {
      case GridState.square:
        return 'tiles are quadratic';
      case GridState.vertical:
        return 'tiles expand vertically';
      case GridState.omni:
        return 'tiles adapt their size';
      default:
        return '???';
    }
  }

  IconData getIcon(GridState state) {
    switch (state) {
      case GridState.square:
        return Icons.view_module;
      case GridState.vertical:
        return Icons.view_column;
      case GridState.omni:
        return Icons.view_quilt;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Staggered'),
      subtitle: Text(getDescription(state)),
      leading: Icon(getIcon(state)),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: Text('Grid'),
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: GridState.values
                        .map((state) => ListTile(
                              trailing: Icon(getIcon(state)),
                              title: Text(getDescription(state)),
                              onTap: () {
                                onChange(state);
                                Navigator.of(context).maybePop();
                              },
                            ))
                        .toList(),
                  )
                ],
              );
            });
      },
    );
  }
}
