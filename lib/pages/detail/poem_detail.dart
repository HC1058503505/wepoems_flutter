import 'package:flutter/material.dart';
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
  PoemAnalyzeView _fanyisAnalyzeView;
  PoemAnalyzeView _shangxisAnalyzeView;
  PoemAuthorView _authorView;
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

    _getPoemDetail();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tabController.dispose();
    DioManager.singleton.cancle();
  }

  void _getPoemDetail() async {
    var postData = {"token": "gswapi", "id": widget.poemRecom.idnew};
    try {
      var response = await DioManager.singleton
          .post(path: "api/shiwen/shiwenv.aspx", data: postData);
      setState(() {
        _detailModel = PoemDetailModel.parseJSON(response);
        _detailModel.author.nameStr = widget.poemRecom.author;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.star_border, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(icon: Icon(Icons.share), onPressed: () {}),
            IconButton(icon: Icon(Icons.more_horiz), onPressed: () {})
          ],
        ),
        body: Container(
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
                      padding: EdgeInsets.all(20),
                      child: poemAnalyzePageView(index),
                    );
                  },
                  childCount: analyzesCount(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  int analyzesCount() {
    if (_detailModel == null) {
      return 0;
    }
    switch (_tabController.index) {
      case 0:
        return _detailModel.fanyis.length;
      case 1:
        return _detailModel.shagnxis.length;
      case 2:
        return 1;
    }
  }

  Container poemHeader() {

    if (widget.poemRecom.cont.length == 0 && _detailModel != null && _detailModel.gushiwen.cont.length > 0) {
      widget.poemRecom.cont = _detailModel.gushiwen.cont;
      widget.poemRecom.tag = _detailModel.gushiwen.tag;
      widget.poemRecom.chaodai = _detailModel.gushiwen.chaodai;
    }

    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          PoemCell(poem: widget.poemRecom),
          PoemTagPage(tagStr: widget.poemRecom.tag)
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
            indicatorColor: Colors.blue,
            tabs: _tabs.map<Tab>((tab) {
              int index = _tabs.indexOf(tab);
              bool isCurrentTab = _tabController.index == index;
              return Tab(
                child: Text(
                  tab["title"],
                  style: TextStyle(
                    color: isCurrentTab ? Colors.blue : Colors.black26,
                  ),
                ),
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
