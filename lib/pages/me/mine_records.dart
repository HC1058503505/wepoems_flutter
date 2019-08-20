import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:wepoems_flutter/models/poem_recommend.dart';
import 'package:wepoems_flutter/pages/recommand/poem_cell.dart';
import 'package:wepoems_flutter/pages/detail/poem_detail.dart';
import 'dart:io';
import 'package:wepoems_flutter/pages/taglist/poems_list_cell.dart';
import 'package:oktoast/oktoast.dart';
import 'package:wepoems_flutter/pages/detail/loading.dart';
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
    dismissAllToast();
    PoemRecommendProvider.singleton.close();
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

  void sureClear() async{
    PoemRecommendProvider provider = PoemRecommendProvider.singleton;
    await provider.open(DatabasePath);

    provider.deleteAll(tableName: tableRecords).then((dynamic) {
      Navigator.of(context).pop();
      showToast("清除成功", position: ToastPosition.center);
      setState(() {
        _records.clear();
      });
    }).catchError((error) {
      showToast("清除失败", position: ToastPosition.center);
    }).whenComplete(() {});
  }

  void sliderDelete(int index) async {
    PoemRecommendProvider provider =
        PoemRecommendProvider.singleton;

    await provider.open(DatabasePath);
    provider
        .delete(
        tableName: tableRecords, id: _records[index].idnew)
        .then((dynamic) {
      showToast("删除浏览记录成功", position: ToastPosition.center);

      setState(() {
        _records.removeAt(index);
      });
    }).catchError((error) {
      showToast("删除浏览记录失败", position: ToastPosition.center);
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
            padding: EdgeInsets.fromLTRB(MediaQuery.of(context).padding.left, 0, MediaQuery.of(context).padding.right, MediaQuery.of(context).padding.bottom),
            controller: _scrollController,
            itemBuilder: (context, index) {
              if (_records.length == 0) {
                return null;
              }

              if (index == _records.length) {
                return LoadingActivityIndicator();
              }

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
                  sliderDelete(index);
                },
                background: new Container(color: Colors.red),
              );
            },
            itemCount:  _records.length + 1,
          ),
          onRefresh: _onRefresh),
    );
  }
}
