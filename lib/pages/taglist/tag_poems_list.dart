import 'package:flutter/material.dart';
import 'package:wepoems_flutter/tools/dio_manager.dart';
import 'package:wepoems_flutter/models/poem_recommend.dart';
import 'package:wepoems_flutter/pages/taglist/poems_list_cell.dart';

enum TagType { Normal, Author, Dynasty, Collections, Category }

class PoemsTagList extends StatefulWidget {
  PoemsTagList({this.tagType, this.tagStr});
  final TagType tagType;
  final String tagStr;

  @override
  _PoemsTagListState createState() => _PoemsTagListState();
}

class _PoemsTagListState extends State<PoemsTagList> {
  int _page = 1;
  String _navTitle = "";
  Map<String, dynamic> _postData = <String, dynamic>{};
  ScrollController _scrollController;
  List<PoemRecommend> _poemList = <PoemRecommend>[];
  bool _isError = false;
  int _sumPage = 1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        _page++;
        _getMoreTagList();
      }
    });

    _postData = {"token": "gswapi", "id": "", "page": _page};
    if (widget.tagType == TagType.Normal ||
        widget.tagType == TagType.Collections) {
      _postData.addAll({"tstr": widget.tagStr});
      _navTitle =
          (widget.tagType == TagType.Normal ? "标签." : "诗集.") + widget.tagStr;
    } else if (widget.tagType == TagType.Dynasty) {
      _postData.addAll({"cstr": widget.tagStr});
      _navTitle = "朝代." + widget.tagStr;
    } else if (widget.tagType == TagType.Author) {
      _postData.addAll({"astr": widget.tagStr});
      _navTitle = "诗人." + widget.tagStr;
    }

    _getMoreTagList();
  }

  void _getMoreTagList() async {
    if (_page > _sumPage) {
      return;
    }
    DioManager.singleton
        .post(path: "api/shiwen/Default.aspx", data: _postData)
        .then((response) {
          _sumPage = response["sumPage"] as int;
          List<dynamic> gushiwens = response["gushiwens"] as List<dynamic>;
          List<PoemRecommend> poems = gushiwens.map<PoemRecommend>((gushiwen) {
          return PoemRecommend.parseJSON(gushiwen);
      }).toList();

      if (_page == 1) {
        _poemList.clear();
      }

      setState(() {
        _poemList.addAll(poems);
      });
    }).catchError((error) {
      setState(() {
        _isError = true;
      });
    });
  }

  Future<void> _refresh() async {
    _page = 1;
    _getMoreTagList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isError) {
      _isError = false;
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(_navTitle),
        ),
        body: GestureDetector(
          onTap: () {
            _getMoreTagList();
          },
          child: Container(
            child: Center(
              child: Text(
                "点击重试",
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_navTitle),
      ),
      body: Stack(
        children: <Widget>[
          RefreshIndicator(
              child: ListView.builder(
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    return PoemsListCell(
                        poem: _poemList[index],
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0));
                  },
                  itemCount: _poemList.length
              ),
              onRefresh: _refresh
          ),
          Offstage(
            offstage: _poemList.length > 0,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        ],
      ),
    );
  }
}
