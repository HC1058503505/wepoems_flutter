import 'package:flutter/material.dart';
import 'package:wepoems_flutter/models/poem_detail_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wepoems_flutter/tools/dio_manager.dart';
import 'package:wepoems_flutter/models/poem_recommend.dart';
import 'package:flutter_html/flutter_html.dart';

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
    getMoreMsg();
  }

  void getMoreMsg() async {
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
    String imageURL =
        "https://img.gushiwen.org" + "/authorImg/" + widget.author.pic + ".jpg";

//    return poemRecomView();
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Padding(
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
          Text(widget.author.cont),
          poemRecomView(),
//          analyzesView()
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

    List<Widget> poemWidgets = _poemRecoms.map<Widget>((peom) {
      print(peom.cont.split(RegExp("<br />")).first);
      return Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(peom.nameStr,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              Text(peom.author + '/' + peom.chaodai,
                  style: TextStyle(color: Colors.black26))
            ],
          ),
          Text(peom.cont.split(RegExp("<br />")).first,
              style: TextStyle(color: Colors.black)),
          Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            height: 2,
            color: Colors.black12,
          )
        ],
      );
    }).toList();

    var raiseBtn = RaisedButton(child: Text("查看更多"), onPressed: () {});
    poemWidgets.add(raiseBtn);

    return Column(
      children: poemWidgets,
    );
  }

  Widget analyzesView() {
    if (_analyzes.length == 0) {
      return ListView.builder(
          itemBuilder: (contenxt, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    _analyzes[index].nameStr,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
                Html(
                  data: _analyzes[index].cont,
                )
              ],
            );
          },
          itemCount: _analyzes.length);
    }
  }
}
