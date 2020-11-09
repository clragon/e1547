import 'package:e1547/denylist/components/deny_card.dart';
import 'package:e1547/interface/pop_menu_tile.dart';
import 'package:flutter/material.dart';

class DenyListBody extends StatelessWidget {
  final List<String> denylist;
  final void Function(int) onEdit;
  final void Function(int) onDelete;

  const DenyListBody(
      {@required this.denylist,
      @required this.onEdit,
      @required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (denylist.length == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check,
              size: 32,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text('Your blacklist is empty'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: denylist.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Wrap(
                      direction: Axis.horizontal,
                      children: () {
                        List<Widget> rows = [];
                        if (denylist.length > 0) {
                          List<String> tags = denylist[index].split(' ');
                          for (String tag in tags) {
                            if (tag.isEmpty) {
                              continue;
                            }
                            rows.add(DenyTagCard(tag));
                          }
                          return rows;
                        } else {
                          return [Container()];
                        }
                      }(),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          PopupMenuItem(
                            value: 'edit',
                            child: PopMenuTile(title: 'Edit', icon: Icons.edit),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: PopMenuTile(
                                title: 'Delete', icon: Icons.delete),
                          ),
                        ],
                        onSelected: (value) async {
                          switch (value) {
                            case 'edit':
                              onEdit(index);
                              break;
                            case 'delete':
                              onDelete(index);
                              break;
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Divider()
            ],
          ),
        );
      },
      physics: BouncingScrollPhysics(),
    );
  }
}
