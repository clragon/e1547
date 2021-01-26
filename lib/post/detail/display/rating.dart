import 'package:e1547/post.dart';
import 'package:flutter/material.dart';

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

Map<String, String> ratings = {
  's': 'Safe',
  'q': 'Questionable',
  'e': 'Explicit',
};

class RatingDisplay extends StatefulWidget {
  final Post post;

  const RatingDisplay({@required this.post});

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
                  child: RatingDialog(onTap: (rating) {
                    widget.post.rating.value = rating;
                  }))
              : () {},
        ),
        Divider(),
      ],
    );
  }
}

class RatingDialog extends StatelessWidget {
  final Function(String rating) onTap;

  const RatingDialog({@required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rating'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: ratings.entries
            .map((entry) => ListTile(
                  title: Text(entry.value),
                  leading: Icon(getIcon(entry.key)),
                  onTap: () {
                    onTap(entry.key);
                    Navigator.of(context).pop();
                  },
                ))
            .toList(),
      ),
    );
  }
}
