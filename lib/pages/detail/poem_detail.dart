import 'package:flutter/material.dart';
import 'package:wepoems_flutter/models/poem_recommend.dart';
import 'package:wepoems_flutter/tools/dio_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:wepoems_flutter/models/poem_detail_model.dart';
import 'package:wepoems_flutter/pages/recommand/poem_cell.dart';
import 'package:wepoems_flutter/pages/detail/poem_anlyze_page.dart';
import 'package:wepoems_flutter/pages/detail/poem_author.dart';

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
  PageController _pageController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _pageController.jumpToPage(_tabController.index);
        });
      }
    });

    _getPoemDetail();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tabController.dispose();
    _pageController.dispose();
    DioManager.singleton.cancle();
  }

  void _getPoemDetail() async {
    var postData = {"token": "gswapi", "id": widget.poemRecom.idnew};
    try {
      var response = await DioManager.singleton
          .post(path: "api/shiwen/shiwenv.aspx", data: postData);

      setState(() {
        _detailModel = PoemDetailModel.parseJSON(response);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.star_border, color: Colors.white),
              onPressed: () {}),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              child: PoemCell(poem: widget.poemRecom),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: TabBar(
                isScrollable: true,
                controller: _tabController,
                indicatorColor: Colors.red,
                tabs: _tabs.map<Tab>((tab) {
                  int index = _tabs.indexOf(tab);
                  bool isCurrentTab = _tabController.index == index;
                  return Tab(
                    child: Text(tab["title"],
                        style: TextStyle(
                            color: isCurrentTab ? Colors.red : Colors.black26)),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  if (index != _tabController.index) {
                    setState(() {
                      _tabController.index = index;
                    });
                  }
                },
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  if (_detailModel == null) {
                    return Container();
                  }
                  List<PoemAnalyze> analyzes = <PoemAnalyze>[];
                  switch (index) {
                    case 0:
                      analyzes = _detailModel.fanyis;
                      return PoemAnalyzeView(analyzes: analyzes);
                    case 1:
                      analyzes = _detailModel.shagnxis;
                      return PoemAnalyzeView(analyzes: analyzes);
                    default:
                      return PoemAuthorView(author: _detailModel.author);
                  }
                  return Container(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(
                          children: analyzes.map<Html>((detail) {
                            return Html(
                              data: detail.cont,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
