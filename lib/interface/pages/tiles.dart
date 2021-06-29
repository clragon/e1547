import 'package:e1547/interface.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

mixin TileSizeMixin<T extends StatefulWidget> on State<T> {
  double tileHeightFactor = 1.2;
  int tileSize;

  void update() {
    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> updateTileSize() async {
    await db.tileSize.value.then((value) {
      tileSize = value;
      update();
    });
  }

  int crossAxisCount(double width) {
    assert(tileSize != null);
    return notZero(width / tileSize).round();
  }

  @override
  void initState() {
    super.initState();
    db.tileSize.addListener(updateTileSize);
    updateTileSize();
  }

  @override
  void reassemble() {
    super.reassemble();
    db.tileSize.removeListener(updateTileSize);
    db.tileSize.addListener(updateTileSize);
  }

  @override
  void dispose() {
    super.dispose();
    db.tileSize.removeListener(updateTileSize);
  }
}

mixin TileStaggerMixin<T extends StatefulWidget> on State<T> {
  GridState stagger;

  void updateStagger() {
    db.stagger.value.then((value) {
      setState(() {
        stagger = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    db.stagger.addListener(updateStagger);
    updateStagger();
  }

  @override
  void reassemble() {
    super.reassemble();
    db.stagger.removeListener(updateStagger);
    db.stagger.addListener(updateStagger);
  }

  @override
  void dispose() {
    super.dispose();
    db.stagger.removeListener(updateStagger);
  }
}
