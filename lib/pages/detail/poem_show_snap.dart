import 'package:flutter/material.dart';
import 'dart:io';

class ShowSnapImg extends StatefulWidget {
  final String snapImgPath;

  ShowSnapImg({this.snapImgPath});

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
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: <Widget>[
        Positioned(
          top: _top,
          left: _left,
          width: MediaQuery.of(context).size.width,
          child: GestureDetector(
            child: Hero(
              tag: "hero",
              child: Image.file(File(widget.snapImgPath)),
            ),
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
    );
  }
}
