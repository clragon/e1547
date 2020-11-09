import 'package:flutter/material.dart';

class SpoilerWrap extends StatefulWidget {
  final Widget child;

  const SpoilerWrap({@required this.child});

  @override
  _SpoilerWrapState createState() => _SpoilerWrapState();
}

class _SpoilerWrapState extends State<SpoilerWrap> {
  bool isShown = false;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: InkWell(
      child: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [widget.child],
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: isShown ? 0 : 1,
              duration: Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text('SPOILER',
                      style: TextStyle(
                        color: Colors.white,
                      )),
                ),
              ),
            ),
          )
        ],
      ),
      onTap: () => setState(() => isShown = !isShown),
    ));
  }
}
