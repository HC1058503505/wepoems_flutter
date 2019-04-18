import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:wepoems_flutter/tools/dio_manager.dart';
import 'package:wepoems_flutter/models/poem_recommend.dart';

class SearchController extends StatefulWidget {
  @override
  _SearchControllerState createState() => _SearchControllerState();
}

class _SearchControllerState extends State<SearchController> {
  TextEditingController _editingController = TextEditingController();
  List<Map<String, dynamic>> _searchResult = List<Map<String, dynamic>>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _getSearchResult() async {
    var postDS = {"token": "gswapi", "valuekey": _editingController.text};
    var response = await DioManager.singleton
        .post(path: "/api/ajaxSearch3.aspx", data: postDS);
    List<dynamic> gushiwens = response["gushiwens"] as List<dynamic>;
    List<dynamic> mingjus = response["mingjus"] as List<dynamic>;
    List<dynamic> authors = response["authors"] as List<dynamic>;

    List<PoemRecommend> gushiwenList = gushiwens.map<PoemRecommend>((item) {
      return PoemRecommend.parseJSON(item);
    }).toList();

    List<PoemRecommend> mingjuList = gushiwens.map<PoemRecommend>((item) {
      return PoemRecommend.parseJSON(item);
    }).toList();

    List<PoemRecommend> authorList = gushiwens.map<PoemRecommend>((item) {
      return PoemRecommend.parseJSON(item);
    }).toList();

    setState(() {
      if (gushiwenList.length > 0) {
        _searchResult.add({"title": "诗文", "results": gushiwenList});
      }

      if (mingjuList.length > 0) {
        _searchResult.add({"title": "名句", "results": mingjuList});
      }

      if (authorList.length > 0) {
        _searchResult.add({"title": "诗人", "results": authorList});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("发现"),
      ),
      body: Column(
        children: <Widget>[
          _searchView(),
          Offstage(
            offstage: _searchResult.length != 0,
            child: ListView.separated(
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    Container(
                      child: Text(_searchResult[index]["title"]),
                    )
                  ],
                );
              },
              separatorBuilder: (context, index) {},
              itemCount: _searchResult.length,
            ),
          )
        ],
      ),
    );
  }

  Widget _searchView() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      decoration: BoxDecoration(
          border: Border.all(
              color: Colors.black26, width: 1, style: BorderStyle.solid),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: TextField(
        controller: _editingController,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(Icons.search),
          labelText: "请输入关键字",
          labelStyle: TextStyle(color: Colors.black26),
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (searchContent) {
          _getSearchResult();
        },
      ),
    );
  }
}
