import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:wepoems_flutter/models/poem_recommend.dart';
import 'package:wepoems_flutter/pages/recommand/poem_cell.dart';
import 'package:wepoems_flutter/pages/detail/poem_detail.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:wepoems_flutter/pages/taglist/poems_list_cell.dart';

class MineRecords extends StatefulWidget {
  @override
  _MineRecordsState createState() => _MineRecordsState();
}

class _MineRecordsState extends State<MineRecords> {
  int _page = 0;
  List<PoemRecommend> _records = List<PoemRecommend>();
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _page++;
        _getCollections();
      }
    });
    _getCollections();
  }

  void _getCollections() async {
    PoemRecommendProvider provider = PoemRecommendProvider.singleton;
    await provider.open(DatabasePath);
//    await provider.getRecords();
    provider
        .getPoemRecomsPaging(tableName: tableRecords, limit: 10, page: _page)
        .then((collectionList) {
      if (collectionList == null) {
        return;
      }

      if (_page == 0) {
        _records.clear();
      }

      setState(() {
        _records.addAll(collectionList);
      });
    }).catchError((error) {
      print(error.toString());
    });
  }

  Future _onRefresh() async {
    _page = 0;
    _getCollections();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
    Fluttertoast.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("浏览记录"),
        actions: <Widget>[
          Offstage(
            offstage: _records == null || _records.length <= 0,
            child: IconButton(
                icon: Icon(Icons.delete, color: Colors.white),
                onPressed: () {
                  clearCollections();
                }),
          ),
        ],
      ),
      body: collectionsListView(),
    );
  }

  void sureClear() {
    PoemRecommendProvider provider = PoemRecommendProvider.singleton;
    provider.deleteAll().then((dynamic) {
      Navigator.of(context).pop();
      Fluttertoast.showToast(
          msg: "清除成功",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);

      setState(() {
        _records.clear();
      });
    }).catchError((error) {
      Fluttertoast.showToast(
          msg: "清除失败",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER);
    }).whenComplete(() {});
  }

  void clearCollections() {
    if (!Platform.isIOS && !Platform.isMacOS) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("温馨提示"),
              content: Text("确定清除全部收浏览记录吗？"),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    sureClear();
                  },
                  child: Text(
                    "确定",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "取消",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            );
          });
      return;
    }

    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("温馨提示"),
            content: Text("确定清除全部浏览记录吗？"),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text(
                  "取消",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: Text(
                  "确定",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onPressed: () {
                  sureClear();
                },
              )
            ],
          );
        });
  }

  Widget collectionsListView() {
    if (_records == null || _records.length == 0) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Text("您的浏览记录空空如也哦！"),
        ),
      );
    }
    return Container(
      color: Colors.white,
      child: RefreshIndicator(
          child: ListView.builder(
            controller: _scrollController,
            itemBuilder: (context, index) {
              return Dismissible(
                direction: DismissDirection.endToStart,
                key: Key(_records[index].idnew),
                child: GestureDetector(
//                  child: PoemCell(poem: _records[index], showStyle: PoemShowStyle.PoemShowSingleLine,),
                  child: PoemsListCell(
                    poem: _records[index],
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    pushContext: context,
                  ),
                  onTap: () {
                    Navigator.of(context)
                        .push(CupertinoPageRoute(builder: (context) {
                      return PoemDetail(poemRecom: _records[index]);
                    }));
                  },
                ),
                onDismissed: (direction) {
                  PoemRecommendProvider provider =
                      PoemRecommendProvider.singleton;
                  provider
                      .delete(
                          tableName: tableCollection, id: _records[index].idnew)
                      .then((dynamic) {
                    Fluttertoast.showToast(
                        msg: "删除浏览记录成功",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER);

                    setState(() {
                      _records.removeAt(index);
                    });
                  }).catchError((error) {
                    Fluttertoast.showToast(
                        msg: "删除浏览记录失败",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER);
                  }).whenComplete(() {});
                },
                background: new Container(color: Colors.red),
              );
            },
            itemCount: _records == null ? 0 : _records.length,
          ),
          onRefresh: _onRefresh),
    );
  }
}
