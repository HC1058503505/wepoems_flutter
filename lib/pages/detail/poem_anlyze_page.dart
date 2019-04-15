import 'package:flutter/material.dart';
import 'package:wepoems_flutter/models/poem_detail_model.dart';
import 'package:flutter_html/flutter_html.dart';

class PoemAnalyzeView extends StatelessWidget {
  PoemAnalyzeView({this.analyzes});
  final List<PoemAnalyze> analyzes;

  @override
  Widget build(BuildContext context) {
    if (analyzes == null) {
      return Container();
    }

    return Container(
      child: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: ListView.builder(
            itemCount: analyzes.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      analyzes[index].nameStr,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Html(
                    data: analyzes[index].cont,
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
