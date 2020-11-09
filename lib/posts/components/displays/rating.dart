import 'package:e1547/posts/post.dart';
import 'package:flutter/material.dart';

class RatingDisplay extends StatefulWidget {
  final Post post;

  const RatingDisplay(this.post);

  @override
  _RatingDisplayState createState() => _RatingDisplayState();
}

class _RatingDisplayState extends State<RatingDisplay> {
  @override
  void initState() {
    super.initState();
    widget.post.rating.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    widget.post.rating.removeListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    IconData getIcon(String rating) {
      switch (rating) {
        case 's':
          return Icons.check_circle_outline;
        case 'q':
          return Icons.help_outline;
        case 'e':
          return Icons.warning;
        default:
          return Icons.error_outline;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            right: 4,
            left: 4,
            top: 2,
            bottom: 2,
          ),
          child: Text(
            'Rating',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
        ListTile(
          title: Text(ratings[widget.post.rating.value]),
          leading: Icon(!widget.post.raw['flags']['rating_locked']
              ? getIcon(widget.post.rating.value)
              : Icons.lock),
          onTap: !widget.post.raw['flags']['rating_locked']
              ? () => showDialog(
                  context: context,
                  child: AlertDialog(
                    title: Text('Rating'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: () {
                        List<Widget> choices = [];
                        ratings.forEach((k, v) {
                          choices.add(ListTile(
                            title: Text(v),
                            leading: Icon(getIcon(k)),
                            onTap: () {
                              widget.post.rating.value = k.toLowerCase();
                              Navigator.of(context).pop();
                            },
                          ));
                        });
                        return choices;
                      }(),
                    ),
                  ))
              : () {},
        ),
        Divider(),
      ],
    );
  }
}
