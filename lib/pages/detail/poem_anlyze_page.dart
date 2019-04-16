import 'package:flutter/material.dart';
import 'package:wepoems_flutter/models/poem_detail_model.dart';
import 'package:flutter_html/flutter_html.dart';

class PoemAnalyzeView extends StatelessWidget {
  PoemAnalyzeView({this.analyzes, this.index});
  final List<PoemAnalyze> analyzes;
  final int index;

  @override
  Widget build(BuildContext context) {
    print("PoemAnalyzeView");
    if (analyzes == null) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            analyzes[index].nameStr,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
        ),
        Html(
          data: analyzes[index].cont,
        )
      ],
    );
  }
}
