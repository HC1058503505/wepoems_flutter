import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:wepoems_flutter/models/poem_detail_model.dart';
import 'package:wepoems_flutter/tools/dio_manager.dart';
import 'package:wepoems_flutter/pages/detail/poem_author.dart';

class PoemSearchAuthor extends StatefulWidget {
  PoemSearchAuthor({this.author});
  final PoemAuthor author;
  @override
  _PoemSearchAuthorState createState() => _PoemSearchAuthorState();
}

class _PoemSearchAuthorState extends State<PoemSearchAuthor> {
  PoemAuthor _authorInfo;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    _getAuthorInfo();
  }

  void _getAuthorInfo() async {
    dynamic postData = {'token': 'gswapi', 'id': widget.author.idnew};
    dynamic response = await DioManager.singleton
        .post(path: "/api/author/author2.aspx", data: postData);

    PoemAuthor authorTemp = PoemAuthor.parseJSON(response["tb_author"]);
    setState(() {
      _authorInfo = authorTemp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.author.nameStr),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: EdgeInsets.all(20),
                  child: PoemAuthorView(author: widget.author),
                );
              },
              childCount: 1,
            ),
          )
        ],
      ),
    );
  }
}
