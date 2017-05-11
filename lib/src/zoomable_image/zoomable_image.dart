// e1547: A mobile app for browsing e926.net and friends.
// Copyright (C) 2017 perlatus <perlatus@e1547.email.vczf.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:vector_math/vector_math_64.dart';

class ZoomableImage extends StatefulWidget {
  ZoomableImage(this.image, {Key key, this.scale = 2.0}) : super(key: key);

  final ImageProvider image;
  final double scale;

  @override
  _ZoomableImageState createState() => new _ZoomableImageState(scale);
}

// See /flutter/examples/layers/widgets/gestures.dart
class _ZoomableImageState extends State<ZoomableImage> {
  _ZoomableImageState(this._scale);

  final double _scale;

  ImageStream _imageStream;
  ui.Image _image;

  // These values are treated as if unscaled.

  Offset _startingFocalPoint;

  Offset _previousOffset;
  Offset _offset = Offset.zero;

  double _previousZoom;
  double _zoom = 1.0;

  void _handleScaleStart(ScaleStartDetails d) {
    _startingFocalPoint = d.focalPoint / _scale;
    _previousOffset = _offset;
    _previousZoom = _zoom;
  }

  void _handleScaleUpdate(Size size, ScaleUpdateDetails d) {
    double newZoom = _previousZoom * d.scale;
    bool tooZoomedIn = _image.width * _scale / newZoom <= size.width ||
        _image.height * _scale / newZoom <= size.height;
    if (tooZoomedIn) {
      return;
    }

    setState(() {
      _zoom = newZoom;

      // Ensure that item under the focal point stays in the same place despite zooming
      final Offset normalizedOffset =
          (_startingFocalPoint - _previousOffset) / _previousZoom;
      _offset = d.focalPoint / _scale - normalizedOffset * _zoom;
    });
  }

  @override
  void didChangeDependencies() {
    _resolveImage();
    super.didChangeDependencies();
  }

  @override
  void reassemble() {
    _resolveImage(); // in case the image cache was flushed
    super.reassemble();
  }

  void _resolveImage() {
    _imageStream = widget.image.resolve(createLocalImageConfiguration(context));
    _imageStream.addListener(_handleImageLoaded);
  }

  void _handleImageLoaded(ImageInfo info, bool synchronousCall) {
    print("image loaded: $info");
    setState(() {
      _image = info.image;
    });
  }

  @override
  void dispose() {
    _imageStream.removeListener(_handleImageLoaded);
    super.dispose();
  }

  Widget _child() {
    if (_image == null) {
      return null;
    }

    // Painting in a small box and blowing it up works, whereas painting in a large box and
    // shrinking it down doesn't because the gesture area becomes smaller than the screen.
    //
    // This is bit counterintuitive because it's backwards, but it works.

    Widget bloated = new CustomPaint(
      painter: new _ZoomableImagePainter(
        image: _image,
        offset: _offset,
        zoom: _zoom / _scale,
      ),
    );

    return new Transform(
      transform: new Matrix4.diagonal3Values(_scale, _scale, _scale),
      child: bloated,
    );
  }

  @override
  Widget build(BuildContext ctx) {
    return new GestureDetector(
      child: _child(),
      onScaleStart: _handleScaleStart,
      onScaleUpdate: (d) => _handleScaleUpdate(ctx.size, d),
    );
  }
}

class _ZoomableImagePainter extends CustomPainter {
  const _ZoomableImagePainter({this.image, this.offset, this.zoom});

  final ui.Image image;
  final Offset offset;
  final double zoom;

  @override
  void paint(Canvas canvas, Size size) {
    paintImage(canvas: canvas, rect: offset & (size * zoom), image: image);
  }

  @override
  bool shouldRepaint(_ZoomableImagePainter old) {
    return old.image != image || old.offset != offset || old.zoom != zoom;
  }
}
