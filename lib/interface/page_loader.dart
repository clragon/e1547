import 'package:flutter/material.dart';

class PageLoader extends StatelessWidget {
  final Widget child;
  final Widget onLoading;
  final Widget onEmpty;
  final bool isLoading;
  final bool isEmpty;

  PageLoader({
    @required this.child,
    @required this.onLoading,
    @required this.onEmpty,
    @required this.isLoading,
    @required this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Visibility(
        visible: isLoading,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: onLoading,
              ),
            ],
          ),
        ),
      ),
      child,
      Visibility(
        visible: (isEmpty),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 32,
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: onEmpty,
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}
