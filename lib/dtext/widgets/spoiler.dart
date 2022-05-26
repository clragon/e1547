import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

class SpoilerWrap extends StatefulWidget {
  final Widget child;

  const SpoilerWrap({required this.child});

  @override
  State<SpoilerWrap> createState() => _SpoilerWrapState();
}

class _SpoilerWrapState extends State<SpoilerWrap> {
  bool visible = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          InkWell(
            onTap: () => setState(() => visible = !visible),
            child: Padding(
              padding: const EdgeInsets.all(8),
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
            child: IgnorePointer(
              ignoring: visible,
              child: InkWell(
                onTap: () => setState(() => visible = !visible),
                child: AnimatedOpacity(
                  opacity: visible ? 0 : 1,
                  duration: defaultAnimationDuration,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
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
          )
        ],
      ),
    );
  }
}
