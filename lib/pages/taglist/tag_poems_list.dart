import 'package:flutter/material.dart';
import 'package:wepoems_flutter/tools/dio_manager.dart';
import 'package:wepoems_flutter/models/poem_recommend.dart';
import 'package:wepoems_flutter/pages/taglist/poems_list_cell.dart';
enum TagType {
  Normal,
  Author,
  Dynasty,
  Collections
}

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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener((){
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent){
        _page++;
        _getMoreTagList();
      }
    });


     _postData = {
      "token": "gswapi",
      "id": "",
      "page": _page
    };
    if(widget.tagType == TagType.Normal || widget.tagType == TagType.Collections){
      _postData.addAll({"tstr" : widget.tagStr});
      _navTitle = (widget.tagType == TagType.Normal ? "标签." : "诗集.") + widget.tagStr;
    } else if(widget.tagType == TagType.Dynasty) {
      _postData.addAll({"cstr" : widget.tagStr});
      _navTitle = "朝代." + widget.tagStr;
    } else if(widget.tagType == TagType.Author) {
      _postData.addAll({"astr" : widget.tagStr});
      _navTitle = "诗人." + widget.tagStr;
    }

    _getMoreTagList();
  }

  void _getMoreTagList() async {
    Map<String, dynamic> response = await DioManager.singleton.post(path: "api/shiwen/Default.aspx", data: _postData) as Map<String, dynamic>;

    List<dynamic> gushiwens = response["gushiwens"] as List<dynamic>;
    List<PoemRecommend> poems = gushiwens.map<PoemRecommend>((gushiwen){
      return PoemRecommend.parseJSON(gushiwen);
    }).toList();

    if (_page == 1) {
      _poemList.clear();
    }

    setState(() {
      _poemList.addAll(poems);
    });

  }

  Future<void> _refresh() {
    _page = 1;
    _getMoreTagList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_navTitle),
      ),
      body: RefreshIndicator(
          child: ListView.separated(
              controller: _scrollController,
              itemBuilder: (context, index){
                return PoemsListCell(poem: _poemList[index], padding: EdgeInsets.fromLTRB(10, 0, 10, 0));
              },
              separatorBuilder: (context,index){
                return Container(
                  height: 1,
                  color: Colors.black12,
                );
              },
              itemCount: _poemList.length
          ),
          onRefresh: _refresh
      ),
    );
  }
}
