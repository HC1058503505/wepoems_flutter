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
  bool _isError = false;
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
    DioManager.singleton
        .post(path: "api/upTimeTop11.aspx", data: postData)
        .then((response) {
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
    }).catchError((error) {
      setState(() {
        _isError = true;
      });
    });
  }

  Future<void> _onRefresh() async {
    _page = 0;
    _getPoems();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      _isError = false;
      return GestureDetector(
        onTap: () {
          _getPoems();
        },
        child: Container(
          child: Center(
            child: Text(
              "点击重试",
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
        ),
      );
    }
    return RefreshIndicator(
        child: ListView.separated(
            controller: _scrollController,
            itemBuilder: (context, index) {
              return GestureDetector(
                child: PoemCell(poem: _recommandList[index]),
                onTap: () {
                  Navigator.of(context)
                      .push(CupertinoPageRoute(builder: (context) {
                    _recommandList[index].from = "recommend";
                    return PoemDetail(poemRecom: _recommandList[index]);
                  }));
                },
              );
            },
            separatorBuilder: (context, index) {
              return Container(
                height: 1,
                color: Colors.black12,
              );
            },
            itemCount: _recommandList.length),
        onRefresh: _onRefresh);
  }
}
