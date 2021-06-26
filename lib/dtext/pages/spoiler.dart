import 'package:flutter/material.dart';

class SpoilerWrap extends StatefulWidget {
  final Widget child;

  const SpoilerWrap({@required this.child});

  @override
  _SpoilerWrapState createState() => _SpoilerWrapState();
}

class _SpoilerWrapState extends State<SpoilerWrap> {
  bool visible = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          InkWell(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [widget.child],
                    ),
                  ),
                ],
              ),
            ),
            onTap: () => setState(() => visible = !visible),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: visible ? 0 : 1,
                duration: Duration(milliseconds: 200),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      'SPOILER',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
