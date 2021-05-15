import 'package:flutter/material.dart';

class SpoilerWrap extends StatefulWidget {
  final Widget child;

  const SpoilerWrap({@required this.child});

  @override
  _SpoilerWrapState createState() => _SpoilerWrapState();
}

class _SpoilerWrapState extends State<SpoilerWrap> {
  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> isShown = ValueNotifier(false);
    return Card(
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
          InkWell(
            child: Positioned.fill(
              child: ValueListenableBuilder(
                valueListenable: isShown,
                builder: (context, value, child) => AnimatedOpacity(
                  opacity: value ? 0 : 1,
                  duration: Duration(milliseconds: 200),
                  child: Card(
                    color: Colors.black,
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
            ),
            onTap: () => isShown.value = !isShown.value,
          ),
        ],
      ),
    );
  }
}
