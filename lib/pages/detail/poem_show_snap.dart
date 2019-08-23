import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

class ShowSnapImg extends StatefulWidget {
  final Image snapImg;
  final Size snapImgSize;
  ShowSnapImg({this.snapImg, this.snapImgSize});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ShowSnapImg();
  }
}

class _ShowSnapImg extends State<ShowSnapImg>
    with SingleTickerProviderStateMixin {
  double _top = 0.0;
  double _left = 0.0;
  double _width = 0.0;
  ScaleGestureRecognizer _scaleGestureRecognizer = ScaleGestureRecognizer();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    double snapImgWHRatio =
        widget.snapImgSize.width / widget.snapImgSize.height;
    double snapImgOriginH = window.physicalSize.width / snapImgWHRatio;
    double centerY = (window.physicalSize.height - snapImgOriginH) *
        (0.5 / window.devicePixelRatio);
    _top = centerY;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: Colors.black,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: _top,
            left: _left,
            width: MediaQuery.of(context).size.width,
            child: GestureDetector(
              child: Hero(tag: "hero", child: widget.snapImg),
              onTap: () {
                Navigator.of(context).pop();
              },
              onPanDown: (DragDownDetails e) {},
              onPanUpdate: (DragUpdateDetails e) {
                setState(() {
                  _left += e.delta.dx;
                  _top += e.delta.dy;
                });
              },
              onPanEnd: (DragEndDetails e) {},
            ),
          )
        ],
      ),
    );
  }
}
