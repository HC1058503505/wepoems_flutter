import 'package:flutter/material.dart';
import 'package:wepoems_flutter/models/poem_recommend.dart';
import 'package:wepoems_flutter/pages/recommand/poem_cell.dart';
import 'package:flutter/cupertino.dart';
import 'package:wepoems_flutter/pages/detail/poem_detail.dart';
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
      ),
      body: ListView.separated(
          itemBuilder: (context, index) {
            return GestureDetector(
              child: PoemCell(poem: _collections[index]),
              onTap: () {
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return PoemDetail(poemRecom: _collections[index]);
                }));
              },
            );
          },
          separatorBuilder: (context, index){
            return Divider(
              color: Colors.black12,
              height: 1,
            );
          },
          itemCount: _collections.length,
      ),
    );
  }
}
