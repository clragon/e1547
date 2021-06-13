import 'package:e1547/interface.dart';
import 'package:flutter/material.dart';

class SpoilerWrap extends StatefulWidget {
  final Widget child;

  const SpoilerWrap({@required this.child});

  @override
  _SpoilerWrapState createState() => _SpoilerWrapState();
}

class _SpoilerWrapState extends State<SpoilerWrap> {
  ValueNotifier<bool> isShown = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
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
        ),
        Positioned.fill(
          child: ValueListenableBuilder(
            valueListenable: isShown,
            builder: (context, value, child) => TweenAnimationBuilder(
                tween:
                    ColorTween(end: value ? Colors.transparent : Colors.black),
                duration: defaultAnimationDuration,
                builder: (context, color, child) {
                  return Card(
                      elevation: 0,
                      color: color,
                      child: InkWell(
                        child: AnimatedOpacity(
                          opacity: value ? 0 : 1,
                          duration: Duration(milliseconds: 200),
                          child: Center(
                            child: Text(
                              'SPOILER',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onTap: () => isShown.value = !isShown.value,
                      ));
                }),
          ),
        ),
      ],
    );
  }
}
