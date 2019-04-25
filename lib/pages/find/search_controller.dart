import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:wepoems_flutter/tools/dio_manager.dart';
import 'package:wepoems_flutter/models/poem_recommend.dart';
import 'package:wepoems_flutter/pages/detail/poem_detail.dart';
import 'package:wepoems_flutter/models/poem_detail_model.dart';
import 'package:wepoems_flutter/pages/detail/poem_search_author.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';

class SearchController extends StatefulWidget {
  @override
  _SearchControllerState createState() => _SearchControllerState();
}

class _SearchControllerState extends State<SearchController> {
  TextEditingController _editingController = TextEditingController();
  List<Map<String, dynamic>> _searchResult = List<Map<String, dynamic>>();
  FocusNode _focusNode = FocusNode();
  bool _isEmpty = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _editingController.dispose();
    _focusNode.dispose();
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

    List<PoemRecommend> mingjuList = mingjus.map<PoemRecommend>((item) {
      return PoemRecommend.parseJSON(item);
    }).toList();

    List<PoemRecommend> authorList = authors.map<PoemRecommend>((item) {
      return PoemRecommend.parseJSON(item);
    }).toList();

    setState(() {
      if (gushiwenList.length > 0) {
        _searchResult
            .add({"title": "诗文", "type": "poem", "results": gushiwenList});
      }

      if (mingjuList.length > 0) {
        _searchResult
            .add({"title": "名句", "type": "mingju", "results": mingjuList});
      }

      if (authorList.length > 0) {
        _searchResult
            .add({"title": "诗人", "type": "author", "results": authorList});
      }

      _isEmpty = _searchResult.length == 0;
    });
  }

  Future unfocusKeyboard() async {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon((Platform.isIOS || Platform.isMacOS)
                ? Icons.arrow_back_ios
                : Icons.arrow_back),
            onPressed: () {
              unfocusKeyboard().then((dynamic) {
                Navigator.of(context).pop();
              });
            }),
        centerTitle: true,
        title: Text("发现"),
      ),
      body: Column(
        children: <Widget>[
          _searchView(),
          Expanded(
            child: Stack(
              children: <Widget>[
                Offstage(
                  offstage: !_isEmpty,
                  child: emptyResult(),
                ),
                Offstage(
                  offstage: _isEmpty,
                  child: searchResult(),
                )
              ],
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
      margin: EdgeInsets.all(20),
      child: TextField(
        focusNode: _focusNode,
        cursorColor: Theme.of(context).primaryColor,
        controller: _editingController,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(Icons.search),
          labelText: "请输入关键字",
          labelStyle: TextStyle(color: Colors.black26),
        ),
        textInputAction: TextInputAction.done,
        onEditingComplete: () {
          if (_focusNode.hasFocus && _editingController.text.length > 0) {
            _focusNode.unfocus();
          }
        },
        onChanged: (searchContent) {
          if (searchContent.length == 0) {
            setState(() {
              _isEmpty = false;
              _searchResult.clear();
            });
          }
        },
        onSubmitted: (searchContent) {
          if (searchContent.length == 0) {
            Fluttertoast.cancel();
            Fluttertoast.showToast(
              msg: "请输入关键字",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
            );
            return;
          }

          _searchResult.clear();
          _getSearchResult();
        },
      ),
    );
  }

//  Text(
//  "没有搜到关于\"${_editingController.text}\"的相关内容",
//  style: TextStyle(color: Colors.black26),
//  )
  Widget emptyResult() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Center(
        child: Text.rich(
          TextSpan(children: [
            TextSpan(
              text: "没有搜到关于",
              style: TextStyle(
                color: Colors.black26,
              ),
            ),
            TextSpan(
              text: "\"${_editingController.text}\"",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: "的相关内容",
              style: TextStyle(
                color: Colors.black26,
              ),
            )
          ]),
          maxLines: 10,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget searchResult() {
    return ListView.separated(
      itemBuilder: (context, index) {
        List<PoemRecommend> resultList = _searchResult[index]["results"];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(_searchResult[index]["title"] + ":"),
              color: Colors.black12,
              padding: EdgeInsets.only(left: 20),
              width: MediaQuery.of(context).size.width,
              height: 40,
              alignment: Alignment.centerLeft,
            ),
            Wrap(
              children: resultList.map<Widget>((item) {
                List<String> splitStrs =
                    item.nameStr.split(_editingController.text);
                List<TextSpan> textSpanWidgets = List<TextSpan>();

                int indexSplit = 0;
                for (String str in splitStrs) {
                  if (str.length == 0 && indexSplit == 0) {
                    TextSpan textSpan = TextSpan(
                      text: _editingController.text,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold),
                    );
                    textSpanWidgets.add(textSpan);
                    indexSplit++;
                    continue;
                  }

                  if (str.length > 0) {
                    TextSpan normalTextSpan = TextSpan(
                      text: str,
                    );
                    textSpanWidgets.add(normalTextSpan);
                  }

                  if (indexSplit == splitStrs.length - 1) {
                    indexSplit++;
                    break;
                  }

                  TextSpan textSpan = TextSpan(
                    text: _editingController.text,
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  );
                  textSpanWidgets.add(textSpan);
                  indexSplit++;
                }

                TextSpan nameStrTextSpan = TextSpan(children: textSpanWidgets);

                return GestureDetector(
                  onTap: () {
                    String type = _searchResult[index]["type"];
                    if (type == "poem") {
                      Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (context) {
                        item.from = "poem";
                        return PoemDetail(poemRecom: item);
                      }));
                    } else if (type == "mingju") {
                      Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (context) {
                        item.from = "mingju";
                        return PoemDetail(poemRecom: item);
                      }));
                    } else if (type == "author") {
                      Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (context) {
                        return PoemSearchAuthor(
                            author: PoemAuthor(
                                idnew: item.idnew, nameStr: item.nameStr));
                      }));
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.only(left: 20),
                    height: 40,
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: Colors.black12,
                                width: 1,
                                style: BorderStyle.solid))),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: Text.rich(nameStrTextSpan),
                          ),
                        ),
                        Offstage(
                          offstage: item.author.length == 0,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(100, 0, 20, 0),
                            child: Text(
                              item.author,
                              style: TextStyle(color: Colors.black26),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }).toList(),
            )
          ],
        );
      },
      separatorBuilder: (context, index) {
        return Container(
          height: 1,
          color: Colors.black26,
        );
      },
      itemCount: _searchResult.length,
    );
  }
}
