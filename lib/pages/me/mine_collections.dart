import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:wepoems_flutter/models/poem_recommend.dart';
import 'package:wepoems_flutter/pages/recommand/poem_cell.dart';
import 'package:wepoems_flutter/pages/detail/poem_detail.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';

class MineCollections extends StatefulWidget {
  @override
  _MineCollectionsState createState() => _MineCollectionsState();
}

class _MineCollectionsState extends State<MineCollections> {
  int _page = 0;
  List<PoemRecommend> _collections = List<PoemRecommend>();
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
    if (!provider.db.isOpen) {
      provider.open(DatabasePath);
    }
    provider.getPoemRecomsPaging(limit: 10, page: _page).then((collectionList) {
      if (collectionList == null) {
//        Fluttertoast.cancel();
//
//        Fluttertoast.showToast(
//            msg: "没有更多数据了",
//            gravity: ToastGravity.CENTER,
//            toastLength: Toast.LENGTH_SHORT);

        return;
      }

      if (_page == 0) {
        _collections.clear();
      }

      setState(() {
        _collections.addAll(collectionList);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("我的收藏"),
        actions: <Widget>[
          Offstage(
            offstage: _collections == null || _collections.length <= 0,
            child: IconButton(
                icon: Icon(Icons.delete, color: Colors.white),
                onPressed: () {
                  if (!Platform.isIOS && !Platform.isMacOS) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("温馨提示"),
                            content: Text("确定清除全部收藏吗？"),
                            actions: <Widget>[
                              FlatButton(onPressed: () {}, child: Text("确定")),
                              FlatButton(onPressed: () {}, child: Text("取消"))
                            ],
                          );
                        });
                  }

                  showCupertinoDialog(
                      context: context,
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: Text("温馨提示"),
                          content: Text("确定清除全部收藏吗？"),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: Text(
                                "取消",
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            CupertinoDialogAction(
                              child: Text(
                                "确定",
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                              onPressed: () {
                                PoemRecommendProvider provider =
                                    PoemRecommendProvider.singleton;
                                provider.deleteAll().then((dynamic) {
                                  Navigator.of(context).pop();
                                  Fluttertoast.showToast(
                                      msg: "清除成功",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER);

                                  setState(() {
                                    _collections.clear();
                                  });
                                }).catchError((error) {
                                  Fluttertoast.showToast(
                                      msg: "清除失败",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER);
                                }).whenComplete(() {});
                              },
                            )
                          ],
                        );
                      });
                }),
          ),
        ],
      ),
      body: collectionsListView(),
    );
  }

  Widget collectionsListView() {
    if (_collections == null || _collections.length == 0) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Text("您的收藏夹空空如也哦！"),
        ),
      );
    }
    return Container(
      color: Colors.white,
      child: RefreshIndicator(
          child: ListView.separated(
            controller: _scrollController,
            itemBuilder: (context, index) {
              return Dismissible(
                direction: DismissDirection.endToStart,
                key: Key(_collections[index].idnew),
                child: GestureDetector(
                  child: PoemCell(poem: _collections[index]),
                  onTap: () {
                    Navigator.of(context)
                        .push(CupertinoPageRoute(builder: (context) {
                      return PoemDetail(poemRecom: _collections[index]);
                    }));
                  },
                ),
                onDismissed: (direction) {
                  PoemRecommendProvider provider =
                      PoemRecommendProvider.singleton;
                  provider.delete(_collections[index].idnew).then((dynamic) {
                    Fluttertoast.showToast(
                        msg: "取消收藏成功",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER);

                    setState(() {
                      _collections.removeAt(index);
                    });
                  }).catchError((error) {
                    Fluttertoast.showToast(
                        msg: "取消收藏失败",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER);
                  }).whenComplete(() {});
                },
                background: new Container(color: Colors.red),
              );
            },
            separatorBuilder: (context, index) {
              return Divider(
                color: Colors.black12,
                height: 1,
              );
            },
            itemCount: _collections == null ? 0 : _collections.length,
          ),
          onRefresh: _onRefresh),
    );
  }
}
