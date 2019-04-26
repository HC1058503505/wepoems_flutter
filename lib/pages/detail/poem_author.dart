import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:wepoems_flutter/models/poem_detail_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wepoems_flutter/tools/dio_manager.dart';
import 'package:wepoems_flutter/models/poem_recommend.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:wepoems_flutter/pages/taglist/poems_list_cell.dart';
import 'package:wepoems_flutter/pages/taglist/tag_poems_list.dart';

enum PoemAuthorType { PoemAuthorBrief, PomeAuthorDetail }

class PoemAuthorView extends StatelessWidget {
  PoemAuthorView({this.poemRecoms, this.analyzes, this.authorInfo});
  final List<PoemRecommend> poemRecoms;
  final List<PoemAnalyze> analyzes;
  final PoemAuthor authorInfo;
//  @override
//  _PoemAuthorViewState createState() => _PoemAuthorViewState();
//}
//
//class _PoemAuthorViewState extends State<PoemAuthorView> {

//  @override
//  void initState() {
//    // TODO: implement initState
//    super.initState();
//  }

//  @override
//  void dispose() {
//    // TODO: implement dispose
//    super.dispose();
//    DioManager.singleton.cancle();
//  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        children: <Widget>[
          Offstage(
            offstage: authorInfo == null || authorInfo.pic == null,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: ClipRRect(
                child: Image(
                  fit: BoxFit.fitHeight,
                  image: CachedNetworkImageProvider(
                      "https://img.gushiwen.org/authorImg/${authorInfo.pic ?? ""}.jpg"),
                  height: 180,
                ),
                borderRadius: BorderRadius.all(Radius.circular(126)),
              ),
            ),
          ),
          Offstage(
            offstage: authorInfo == null || authorInfo.cont == null,
            child: Html(
              data: authorInfo.cont ?? "",
            ),
          ),
          Offstage(
            offstage: poemRecoms == null || poemRecoms.length == 0,
            child: poemRecomView(context),
          ),
          Offstage(
            offstage: analyzes == null || analyzes.length == 0,
            child: analyzesView(),
          ),
          Offstage(
            offstage: authorInfo != null &&
                authorInfo.idnew != null &&
                authorInfo.idnew.length > 0,
            child: Container(
              height: 200,
              child: Center(
                child: Text(
                  authorInfo.nameStr ?? "佚名",
                  style: TextStyle(color: Colors.black26),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget poemRecomView(BuildContext context) {
    List<Widget> poemWidgets = poemRecoms.map<Widget>((poem) {
      return PoemsListCell(poem: poem, padding: EdgeInsets.all(0));
    }).toList();

    var faltBtn = FlatButton(
        child: Text(
          "查看更多>>",
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        onPressed: () {
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
            return PoemsTagList(
              tagType: TagType.Author,
              tagStr: authorInfo.nameStr,
            );
          }));
        });
    poemWidgets.add(faltBtn);

    var titleText = Container(
      child: Text(
        "代表作",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          titleText,
          Column(
            children: poemWidgets,
          )
        ],
      ),
    );
  }

  Widget analyzesView() {
    List<Widget> analyzeWidgets = analyzes.map<Widget>((analyze) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              analyze.nameStr,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
              textAlign: TextAlign.left,
            ),
          ),
          Html(
            data: analyze.cont,
          )
        ],
      );
    }).toList();

    return Column(
      children: analyzeWidgets,
    );
  }

//  @override
//  // TODO: implement wantKeepAlive
//  bool get wantKeepAlive => true;
}
