import 'package:flutter/material.dart';
import 'package:wepoems_flutter/models/poem_recommend.dart';
import 'package:wepoems_flutter/pages/recommand/poem_cell.dart';
import 'package:flutter/cupertino.dart';
import 'package:wepoems_flutter/pages/detail/poem_detail.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MineCollections extends StatefulWidget {
  @override
  _MineCollectionsState createState() => _MineCollectionsState();
}

class _MineCollectionsState extends State<MineCollections> {
  int _page = 0;
  List<PoemRecommend> _collections = List<PoemRecommend>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCollections();
  }

  void _getCollections() async {
    PoemRecommendProvider provider = PoemRecommendProvider.singleton;
    if (!provider.db.isOpen) {
      provider.open(DatabasePath);
    }
    provider.getPoemRecomsPaging(limit: 10, page: _page).then((collectionList) {
      setState(() {
        _collections = collectionList;
      });
    }).catchError((error) {
      print(error.toString());
    });
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
                  PoemRecommendProvider provider =
                      PoemRecommendProvider.singleton;
                  provider.deleteAll().then((dynamic) {
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
                }),
          ),
          Offstage(
            offstage: _collections != null && _collections.length > 0,
            child: IconButton(
                icon: Icon(Icons.add, color: Colors.white,),
                onPressed: (){

                }
            ),
          )
        ],
      ),
      body: collectionsListView(),
    );
  }

  Widget collectionsListView() {
    if (_collections == null || _collections.length == 0) {
      return Container(
        child: Center(
          child: Text("您的收藏夹空空如也哦！"),
        ),
      );
    }
    return ListView.separated(
      itemBuilder: (context, index) {
        return Dismissible(
          direction: DismissDirection.endToStart,
          key: Key(_collections[index].idnew),
          child: GestureDetector(
            child: PoemCell(poem: _collections[index]),
            onTap: () {
              Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
                return PoemDetail(poemRecom: _collections[index]);
              }));
            },
          ),
          onDismissed: (direction) {
            PoemRecommendProvider provider = PoemRecommendProvider.singleton;
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
    );
  }
}
