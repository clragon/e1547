import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class LoadingTile extends StatefulWidget {
  final Widget? leading;
  final Widget title;
  final Widget? trailing;
  final Function onTap;

  const LoadingTile({
    required this.title,
    required this.onTap,
    this.leading,
    this.trailing,
  });

  @override
  _LoadingTileState createState() => _LoadingTileState();
}

class _LoadingTileState extends State<LoadingTile> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: widget.leading,
      title: widget.title,
      trailing: CrossFade(
        child: SizedBox(
          child: Padding(
            padding: EdgeInsets.all(2),
            child: CircularProgressIndicator(),
          ),
          height: 20,
          width: 20,
        ),
        secondChild: widget.trailing ?? Icon(Icons.arrow_right),
        showChild: isLoading,
      ),
      onTap: isLoading
          ? null
          : () async {
              setState(() {
                isLoading = true;
              });
              await widget.onTap();
              setState(() {
                isLoading = false;
              });
            },
    );
  }
}
