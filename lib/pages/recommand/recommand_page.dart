import 'package:flutter/material.dart';
import 'package:wepoems_flutter/models/poem_recommend.dart';
import 'package:wepoems_flutter/pages/recommand/poem_cell.dart';
import 'package:flutter/cupertino.dart';
import 'package:wepoems_flutter/tools/dio_manager.dart';
import 'package:wepoems_flutter/pages/detail/poem_detail.dart';
import 'package:wepoems_flutter/pages/detail/loading.dart';
import 'package:wepoems_flutter/pages/detail/error_retry_page.dart';

class RecommandPage extends StatefulWidget {
  @override
  _RecommandPageState createState() => _RecommandPageState();
}

class _RecommandPageState extends State<RecommandPage> {
  ScrollController _scrollController;
  List<PoemRecommend> _recommandList = <PoemRecommend>[];

  int _page = 0;
  bool _isLoading = false;
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
    if (_recommandList.length == 0) {
      setState(() {
        _isLoading = true;
      });
    }
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
        })
        .catchError((error) {})
        .whenComplete(() {
          if (_isLoading == true) {
            setState(() {
              _isLoading = false;
            });
          }
        });
  }

  Future<void> _onRefresh() async {
    _page = 0;
    _getPoems();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        textDirection: TextDirection.rtl,
        children: <Widget>[
          RefreshIndicator(
            child: ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).padding.left,
                  0,
                  MediaQuery.of(context).padding.right,
                  MediaQuery.of(context).padding.bottom + 20,
                ),
                controller: _scrollController,
                itemBuilder: (context, index) {
                  if (_recommandList.length == 0) {
                    return null;
                  }

                  if (index == _recommandList.length) {
                    return LoadingActivityIndicator();
                  }
                  return GestureDetector(
                    child: PoemCell(
                      poem: _recommandList[index],
                      showStyle: PoemShowStyle.PoemShowMultipleLines,
                    ),
                    onTap: () {
                      Navigator.of(context)
                          .push(CupertinoPageRoute(builder: (context) {
                        _recommandList[index].from = "recommend";
                        _recommandList[index].isCollection = false;
                        return PoemDetail(poemRecom: _recommandList[index]);
                      }));
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return Container(
                    color: Colors.grey.withAlpha(12),
                    child: Divider(
                      color: Colors.transparent,
                    ),
                  );
                },
                itemCount: _recommandList.length + 1),
            onRefresh: _onRefresh,
          ),
          LoadingIndicator(isLoading: _isLoading),
          RetryPage(
            offstage: _isLoading || _recommandList.length > 0,
            onTap: () {
              _getPoems();
            },
          )
        ],
      ),
    );
  }
}
