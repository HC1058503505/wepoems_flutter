import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wepoems_flutter/models/poem_recommend.dart';
import 'package:wepoems_flutter/tools/dio_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:wepoems_flutter/models/poem_detail_model.dart';
import 'package:wepoems_flutter/pages/recommand/poem_cell.dart';
import 'package:wepoems_flutter/pages/detail/poem_anlyze_page.dart';
import 'package:wepoems_flutter/pages/detail/poem_author.dart';
import 'dart:math' as math;
import 'package:wepoems_flutter/pages/detail/poem_tag_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:core';
import 'dart:io';

class PoemDetail extends StatefulWidget {
  PoemDetail({this.poemRecom});
  final PoemRecommend poemRecom;

  @override
  _PoemDetailState createState() => _PoemDetailState();
}

class _PoemDetailState extends State<PoemDetail>
    with SingleTickerProviderStateMixin {
  PoemDetailModel _detailModel;
  List<Map<String, String>> _tabs = <Map<String, String>>[
    {"title": "译注"},
    {"title": "赏析"},
    {"title": "作者"}
  ];
  TabController _tabController;
//  PageController _pageController = PageController();
  PoemAnalyzeView _fanyisAnalyzeView;
  PoemAnalyzeView _shangxisAnalyzeView;
  PoemAuthorView _authorView;
  bool _collectionEnable = true;
//  GlobalKey _rootWidgetKey = GlobalKey();
//  List<Uint8List> _images = List();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    selectedCollection();
  }

  void selectedCollection() async {
    if (widget.poemRecom.from == "collection") {
      _getPoemDetail();
      return;
    }

    PoemRecommendProvider provider = PoemRecommendProvider.singleton;
    if (!provider.db.isOpen) {
      await provider.open(DatabasePath);
    }
    provider
        .getPoemRecom(widget.poemRecom.idnew)
        .then((poem) {
          if (poem != null) {
            widget.poemRecom.isCollection = poem.isCollection;
            widget.poemRecom.nameStr = poem.nameStr;
            widget.poemRecom.author = poem.author;
            widget.poemRecom.chaodai = poem.chaodai;
            widget.poemRecom.cont = poem.cont;
            widget.poemRecom.tag = poem.tag;
            widget.poemRecom.from = "recommend";
          } else {
            widget.poemRecom.isCollection = false;
          }
        })
        .catchError((error) {})
        .whenComplete(() {
          _getPoemDetail();
        });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tabController.dispose();
    DioManager.singleton.cancle();
    Fluttertoast.cancel();
  }

  void _getPoemDetail() async {
    var postData = {"token": "gswapi", "id": widget.poemRecom.idnew};
    String path = widget.poemRecom.from == "mingju"
        ? "api/mingju/juv2.aspx"
        : "api/shiwen/shiwenv.aspx";
    DioManager.singleton.post(path: path, data: postData).then((response) {
      setState(() {
        _detailModel = PoemDetailModel.parseJSON(response);
      });
    }).catchError((error) {
      DioError dioError = error as DioError;
      if (dioError.type == DioErrorType.CONNECT_TIMEOUT) {
        Fluttertoast.showToast(
            msg: "网络连接超时，请检查网络",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER);
      }
    });
  }

//  Future _capturePng() async {
//    try {
//      RenderRepaintBoundary boundary =
//      _rootWidgetKey.currentContext.findRenderObject();
//      var image = await boundary.toImage(pixelRatio: 3.0);
//      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
//      Uint8List pngBytes = byteData.buffer.asUint8List();
//      _images.add(pngBytes);
//      setState(() {});
//      return pngBytes;
//    } catch (e) {
//      print(e);
//    }
//    return null;
//  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        MaterialApp(
          theme: Theme.of(context),
          home: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  icon: Icon((Platform.isMacOS || Platform.isIOS)
                      ? Icons.arrow_back_ios
                      : Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                      _detailModel != null && _detailModel.gushiwen.isCollection
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.white),
                  onPressed: () {
                    Fluttertoast.cancel();

                    if (_detailModel == null ||
                        widget.poemRecom.idnew.length == 0) {
                      return;
                    }

                    if (_collectionEnable == false) {
                      Fluttertoast.showToast(
                          msg: "您的操作太频繁了，稍等！",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER);
                      return;
                    }

                    PoemRecommendProvider provider =
                        PoemRecommendProvider.singleton;
                    if (!_detailModel.gushiwen.isCollection) {
                      _collectionEnable = false;
                      _detailModel.gushiwen.isCollection =
                          !_detailModel.gushiwen.isCollection;
                      provider.insert(_detailModel.gushiwen).then((dynamic) {
                        Fluttertoast.showToast(
                            msg: "收藏成功",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER);
                        setState(() {});
                      }).catchError((error) {
                        Fluttertoast.showToast(
                            msg: "收藏失败",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER);
                      }).whenComplete(() {
                        _collectionEnable = true;
                      });
                    } else {
                      _collectionEnable = false;
                      _detailModel.gushiwen.isCollection =
                          !_detailModel.gushiwen.isCollection;
                      provider
                          .delete(_detailModel.gushiwen.idnew)
                          .then((dynamic) {
                        Fluttertoast.showToast(
                            msg: "取消收藏成功",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER);
                        setState(() {});
                      }).catchError((error) {
                        Fluttertoast.showToast(
                            msg: "取消收藏失败",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER);
                      }).whenComplete(() {
                        _collectionEnable = true;
                      });
                    }
                  },
                ),
//              IconButton(icon: Icon(Icons.share), onPressed: () {}),
//              IconButton(icon: Icon(Icons.camera_alt), onPressed: () {
//                _capturePng().then((value){
//                  Fluttertoast.showToast(
//                      msg: "截图成功",
//                      toastLength: Toast.LENGTH_SHORT,
//                      gravity: ToastGravity.CENTER);
//                });
//              })
              ],
            ),
            body: Offstage(
              offstage: _detailModel == null,
              child: Container(
                color: Colors.white,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: poemHeader(),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      floating: true,
                      delegate: _SliverAppBarDelegate(
                        minHeight: 55,
                        maxHeight: 55,
                        child: poemAnalyzeTabBar(),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: poemAnalyzePageView(index),
                          );
                        },
                        childCount: analyzesCount(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Offstage(
          offstage: _detailModel != null,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        )
      ],
    );
  }

  int analyzesCount() {
    switch (_tabController.index) {
      case 0:
        return _detailModel == null ? 0 : _detailModel.fanyis.length;
      case 1:
        return _detailModel == null ? 0 : _detailModel.shagnxis.length;
      case 2:
        return 1;
    }
  }

  Container poemHeader() {
    if (_detailModel == null && widget.poemRecom.from != "recommend") {
      return Container();
    }

    PoemRecommend source =
        _detailModel == null ? widget.poemRecom : _detailModel.gushiwen;

    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          PoemCell(poem: source),
          PoemTagPage(tagStr: source.tag)
        ],
      ),
    );
  }

  Container poemAnalyzeTabBar() {
    return Container(
      color: Colors.white,
      alignment: Alignment.centerLeft,
      child: Column(
        children: <Widget>[
          TabBar(
            isScrollable: true,
            controller: _tabController,
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.black45,
            tabs: _tabs.map<Tab>((tab) {
              int index = _tabs.indexOf(tab);
              bool isCurrentTab = _tabController.index == index;
              return Tab(
                child: Text(tab["title"]),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget sliverPoemAnalyzeCell(List<PoemAnalyze> analyze, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            analyze[index].nameStr,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
        ),
        Html(
          data: analyze[index].cont,
        )
      ],
    );
  }

  Widget poemAnalyzePageView(int index) {
    switch (_tabController.index) {
      case 0:
        if (_fanyisAnalyzeView == null) {
          _fanyisAnalyzeView =
              PoemAnalyzeView(analyzes: _detailModel.fanyis, index: index);
        }
        return _fanyisAnalyzeView;
      case 1:
        if (_shangxisAnalyzeView == null) {
          _shangxisAnalyzeView =
              PoemAnalyzeView(analyzes: _detailModel.shagnxis, index: index);
        }
        return _shangxisAnalyzeView;
      default:
        if (_authorView == null) {
          _authorView = PoemAuthorView(author: _detailModel.author);
        }
        return _authorView;
    }
  }
}

// 常驻表头代理
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
