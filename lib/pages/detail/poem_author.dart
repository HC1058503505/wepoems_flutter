import 'package:flutter/material.dart';
import 'package:wepoems_flutter/models/poem_detail_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wepoems_flutter/tools/dio_manager.dart';
import 'package:wepoems_flutter/models/poem_recommend.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:wepoems_flutter/pages/taglist/poems_list_cell.dart';
class PoemAuthorView extends StatefulWidget {
  PoemAuthorView({this.author});
  final PoemAuthor author;
  @override
  _PoemAuthorViewState createState() => _PoemAuthorViewState();
}

class _PoemAuthorViewState extends State<PoemAuthorView> {
  List<PoemRecommend> _poemRecoms = <PoemRecommend>[];
  List<PoemAnalyze> _analyzes = <PoemAnalyze>[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getMoreMsg();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    DioManager.singleton.cancle();
  }

  void _getMoreMsg() async {
    if (widget.author.idnew.length == 0) {
      return;
    }
    var postData = {'token': 'gswapi', 'id': widget.author.idnew};
    var response = await DioManager.singleton.post(
        path: "api/author/author2.aspx",
        data: postData) as Map<String, dynamic>;

    var tb_gushiwens = response["tb_gushiwens"] as Map<String, dynamic>;
    var gushiwens = tb_gushiwens["gushiwens"] as List<dynamic>;
    var gushiwensList = gushiwens.map<PoemRecommend>((poem) {
      return PoemRecommend.parseJSON(poem);
    }).toList();

    var tb_ziliaos = response["tb_ziliaos"] as Map<String, dynamic>;
    var ziliaos = tb_ziliaos["ziliaos"] as List<dynamic>;
    var analyzesList = ziliaos.map<PoemAnalyze>((analyze) {
      return PoemAnalyze.parseJSON(analyze);
    }).toList();

    setState(() {
      _poemRecoms = gushiwensList;
      _analyzes = analyzesList;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.author.idnew.length == 0) {
      return Container(
        child: Center(
          child: Text(
            widget.author.nameStr,
            style: TextStyle(color: Colors.black26),
          ),
        ),
      );
    }
    String imageURL =
        "https://img.gushiwen.org" + "/authorImg/" + widget.author.pic + ".jpg";

    return Container(
      child: Column(
        children: <Widget>[
          Offstage(
            offstage: widget.author.pic.length <= 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: ClipRRect(
                child: Image(
                  fit: BoxFit.fitHeight,
                  image: CachedNetworkImageProvider(imageURL),
                  height: 225,
                ),
                borderRadius: BorderRadius.all(Radius.circular(157.5)),
              ),
            ),
          ),
          Html(
            data: widget.author.cont,
          ),
          poemRecomView(),
          analyzesView()
        ],
      ),
    );
  }

  Widget poemRecomView() {
    if (_poemRecoms.length == 0) {
      return Container(
        child: RefreshProgressIndicator(),
      );
    }

    List<Widget> poemWidgets = _poemRecoms.map<Widget>((poem) {
      return PoemsListCell(poem: poem, padding: EdgeInsets.all(0));
    }).toList();

    var raiseBtn = RaisedButton(child: Text("查看更多"), onPressed: () {});
    poemWidgets.add(raiseBtn);

    var titleText = Text("代表作",
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0));
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
    if (_analyzes.length == 0) {
      return Container();
    }

    List<Widget> analyzeWidgets = _analyzes.map<Widget>((analyze) {
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
}
