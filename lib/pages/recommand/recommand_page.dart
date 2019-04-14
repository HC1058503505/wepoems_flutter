import 'package:flutter/material.dart';
import 'package:wepoems_flutter/models/poem_recommend.dart';
import 'package:wepoems_flutter/pages/recommand/poem_cell.dart';
import 'package:flutter/cupertino.dart';
import 'package:wepoems_flutter/tools/dio_manager.dart';
import 'package:wepoems_flutter/pages/detail/poem_detail.dart';

class RecommandPage extends StatefulWidget {
  @override
  _RecommandPageState createState() => _RecommandPageState();
}

class _RecommandPageState extends State<RecommandPage> {
  ScrollController _scrollController;
  List<PoemRecommend> _recommandList = <PoemRecommend>[];

  int _page = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _page++;
        _getPoems();
      }
    });

    _getPoems();
  }

  void _getPoems() async {
    var postData = {"pwd": "", "token": "gswapi", "id": "", "page": _page};
    var response = await DioManager.singleton.post(
        path: "api/upTimeTop11.aspx", data: postData) as Map<String, dynamic>;

    var gushiwens = response["gushiwens"] as List<dynamic>;
    var gushiwenList = gushiwens.map((poem) {
      return PoemRecommend.parseJSON(poem);
    });

    if (_page == 0) {
      _recommandList.clear();
    }

    setState(() {
      _recommandList.addAll(gushiwenList);
    });
  }

  Future<void> _onRefresh() async {
    _page = 0;
    _getPoems();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        child: ListView.separated(
            controller: _scrollController,
            itemBuilder: (context, index) {
              return GestureDetector(
                child: PoemCell(poem: _recommandList[index]),
                onTap: () {
                  Navigator.of(context)
                      .push(CupertinoPageRoute(builder: (context) {
                    return PoemDetail(poemRecom: _recommandList[index]);
                  }));
                },
              );
            },
            separatorBuilder: (context, index) {
              return Container(
                height: 2,
                color: Colors.black12,
              );
            },
            itemCount: _recommandList.length),
        onRefresh: _onRefresh);
  }
}