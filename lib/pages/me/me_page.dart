import 'package:flutter/material.dart';
import 'package:wepoems_flutter/pages/me/mine_collections.dart';
import 'package:flutter/cupertino.dart';
import 'package:wepoems_flutter/pages/me/mine_settings.dart';

class MePage extends StatefulWidget {
  @override
  _MePageState createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  List<MeItem> _items = <MeItem>[
    MeItem(title: "我的收藏", iconData: Icons.star, hasDivider: false),
    MeItem(title: "浏览记录", iconData: Icons.access_time, hasDivider: true),
    MeItem(title: "设置", iconData: Icons.settings, hasDivider: false)
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 20),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            switch (index) {
              case 0:
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return MineCollections();
                }));
                break;
              case 1:
                break;
              case 2:
                Navigator.of(context)
                    .push(CupertinoPageRoute(builder: (context) {
                  return MineSettings();
                }));
                break;
            }
          },
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white10,
                padding: EdgeInsets.only(left: 20),
                height: 40,
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Icon(
                        _items[index].iconData,
                        color: Colors.black45,
                      ),
                    ),
                    Text(_items[index].title)
                  ],
                ),
              ),
              dividerSeparater(_items[index].hasDivider)
            ],
          ),
        );
      },
      itemCount: _items.length,
    );
  }

  Widget dividerSeparater(bool hasDivider) {
    return hasDivider
        ? Container(
            color: Colors.black.withAlpha(5),
            height: 40,
          )
        : Divider(height: 10, color: Colors.black12, indent: 20);
  }
}

class MeItem {
  String title = "";
  IconData iconData;
  bool hasDivider = false;
  MeItem({this.title, this.iconData, this.hasDivider});
}
