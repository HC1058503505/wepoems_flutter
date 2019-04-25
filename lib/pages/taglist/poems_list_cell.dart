import 'package:flutter/material.dart';
import 'package:wepoems_flutter/models/poem_recommend.dart';
import 'package:wepoems_flutter/pages/detail/poem_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';

class PoemsListCell extends StatelessWidget {
  PoemsListCell({this.poem, this.padding});
  final PoemRecommend poem;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return PoemDetail(poemRecom: poem);
        }));
      },
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(poem.nameStr,
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 20),
                  Text(poem.chaodai + ' / ' + poem.author,
                      style: TextStyle(color: Colors.black26))
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 15),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Html(
                  data: poem.cont.replaceAll(RegExp("<div class=\'small\'></div>"), "\n").split(RegExp("\n")).first,
                  defaultTextStyle: TextStyle(color: Colors.black),
                ),
              ),
            ),
            Container(
              height: 1,
              color: Colors.black12,
            )
          ],
        ),
      ),
    );
  }
}
