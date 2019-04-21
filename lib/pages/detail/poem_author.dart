import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:wepoems_flutter/models/poem_detail_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wepoems_flutter/tools/dio_manager.dart';
import 'package:wepoems_flutter/models/poem_recommend.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:wepoems_flutter/pages/taglist/poems_list_cell.dart';
import 'package:wepoems_flutter/pages/taglist/tag_poems_list.dart';

class PoemAuthorView extends StatefulWidget {
  PoemAuthorView({this.author});
  final PoemAuthor author;
  @override
  _PoemAuthorViewState createState() => _PoemAuthorViewState();
}

class _PoemAuthorViewState extends State<PoemAuthorView>  with AutomaticKeepAliveClientMixin{
  List<PoemRecommend> _poemRecoms = <PoemRecommend>[];
  List<PoemAnalyze> _analyzes = <PoemAnalyze>[];
  PoemAuthor _authorInfo;
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
    if (widget.author == null || widget.author.idnew.length == 0) {
      return;
    }
    var postData = {'token': 'gswapi', 'id': widget.author.idnew};
    var response = await DioManager.singleton.post(
        path: "api/author/author2.aspx",
        data: postData) as Map<String, dynamic>;

    PoemAuthor authorTemp = PoemAuthor.parseJSON(response["tb_author"]);

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
      _authorInfo = authorTemp;
      _poemRecoms = gushiwensList;
      _analyzes = analyzesList;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_authorInfo == null || widget.author == null || widget.author.idnew.length == 0) {
      return Container(
        color: Colors.white,
      );
    }

    String imageURL =
        "https://img.gushiwen.org" + "/authorImg/" + _authorInfo.pic + ".jpg";

    return Container(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        children: <Widget>[
          Offstage(
            offstage: _authorInfo.pic.length <= 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: ClipRRect(
                child: Image(
                  fit: BoxFit.fitHeight,
                  image: CachedNetworkImageProvider(imageURL),
                  height: 180,
                ),
                borderRadius: BorderRadius.all(Radius.circular(126)),
              ),
            ),
          ),
          Html(
            data: _authorInfo.cont,
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

    var faltBtn = FlatButton(
        child: Text(
          "查看更多>>",
          style: TextStyle(color: Colors.blue),
        ),
        onPressed: () {
          Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
            return PoemsTagList(
              tagType: TagType.Author,
              tagStr: widget.author.nameStr,
            );
          }));
        });
    poemWidgets.add(faltBtn);

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

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
