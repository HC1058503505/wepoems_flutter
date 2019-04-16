import 'package:flutter/material.dart';
import 'package:wepoems_flutter/models/poem_recommend.dart';
import 'package:flutter_html/flutter_html.dart';

class PoemCell extends StatelessWidget {
  PoemCell({this.poem});

  final PoemRecommend poem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Text(
              poem.nameStr,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                decoration: TextDecoration.none,
              ),
            ),
            padding: EdgeInsets.only(bottom: 10),
            alignment: Alignment.center,
          ),
          Container(
              color: Colors.white,
              child: Text(
                poem.author + '/' + poem.chaodai,
                style: TextStyle(
                  color: Colors.black38,
                  fontSize: 16,
                  decoration: TextDecoration.none,
                ),
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 10)),
          Container(
            alignment: Alignment.center,
            color: Colors.white,
            child: Text(
              poem.cont,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none,
              ),
            ),
          )
        ],
      ),
    );
  }
}
