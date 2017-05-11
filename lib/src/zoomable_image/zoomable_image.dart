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
  _ZoomableImageState(this._scale) : _zoom = _scale;

  final double _scale;

  Offset _startingFocalPoint;

  Offset _previousOffset;
  Offset _offset = Offset.zero;

  double _previousZoom;
  double _zoom;

  void _handleScaleStart(ScaleStartDetails d) {
    _startingFocalPoint = d.focalPoint;
    _previousOffset = _offset;
    _previousZoom = _zoom;
  }

  void _handleScaleUpdate(ScaleUpdateDetails d) {
    setState(() {
      _zoom = _previousZoom * d.scale;

      // Ensure that item under the focal point stays in the same place despite zooming
      final Offset normalizedOffset =
          (_startingFocalPoint - _previousOffset) / _previousZoom;
      _offset = d.focalPoint - normalizedOffset * _zoom;
    });
  }

  ImageStream _imageStream;
  ui.Image _image;

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
        offset: _offset / _scale,
        zoom: _zoom / _scale / _scale,
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
      onScaleUpdate: _handleScaleUpdate,
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
