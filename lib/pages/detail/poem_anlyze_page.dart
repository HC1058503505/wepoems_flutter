import 'package:flutter/material.dart';
import 'package:wepoems_flutter/models/poem_detail_model.dart';
import 'package:flutter_html/flutter_html.dart';

class PoemAnalyzeView extends StatelessWidget {
  PoemAnalyzeView({this.analyzes, this.index});
  final List<PoemAnalyze> analyzes;
  final int index;
//  @override
//  _PoemAnalyzeViewState createState() => _PoemAnalyzeViewState();
//}
//
//class _PoemAnalyzeViewState extends State<PoemAnalyzeView>  with AutomaticKeepAliveClientMixin{
  @override
  Widget build(BuildContext context) {
    if (analyzes == null) {
      return Container(
        color: Colors.white,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 0),
          child: Text(
            analyzes[index].nameStr,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
            textAlign: TextAlign.left,
          ),
        ),
        Html(
          data: analyzes[index].cont,
          defaultTextStyle: TextStyle(fontSize: 15),
        )
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
