import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(new E1547App());
}

class E1547App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'E1547',
      theme: new ThemeData.dark(),
      home: new Scaffold(
        appBar: new AppBar(title: const Text("E1547")),
        body: new GridView.builder(
          gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200.0, // px
          ),
          itemBuilder: (ctx, i) => new Center(child: new Text(i.toString())),
        ),
      ),
    );
  }
}
