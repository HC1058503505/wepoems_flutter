import 'package:flutter/material.dart';
import 'package:wepoems_flutter/pages/root/root_page.dart';
import 'package:wepoems_flutter/models/poem_recommend.dart';
import 'package:wepoems_flutter/tools/bus_event.dart';
import 'package:wepoems_flutter/models/strings.dart';
import 'package:flustars/flustars.dart';
import 'package:wepoems_flutter/models/colors.dart';
import 'package:wepoems_flutter/pages/ad/ad_page.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sharesdk_plugin/sharesdk_plugin.dart';
import 'package:admob_flutter/admob_flutter.dart';

void main() {
  Admob.initialize("ca-app-pub-9502218624604000~3881277138");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color _themeColor;
  bool _hideAd = false;
  @override
  void initState() {
    SpUtil.getInstance().then((value) {
      setState(() {
        _themeColor = themeColorMap[
            SpUtil.getString(Constant.KEY_THEME_COLOR, defValue: "blue")];
      });
    });

    // TODO: implement initState
    super.initState();

    ShareSDKRegister register = ShareSDKRegister();
    register.setupWechat(
        "wx42a569c9434d850c", "da5d5e62231d462b167c7aba10004db6");
    SharesdkPlugin.regist(register);

    bus.add(Constant.KEY_THEME_CHANGE, (dynamic) {
      SpUtil.getInstance().then((value) {
        setState(() {
          _themeColor = themeColorMap[
              SpUtil.getString(Constant.KEY_THEME_COLOR, defValue: "blue")];
        });
      });
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // 建表
    createCollectionTable();

    return OKToast(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData.light().copyWith(
          primaryColor: _themeColor,
          accentColor: _themeColor,
          indicatorColor: Colors.white,
        ),
        home: Stack(
          children: <Widget>[
            RootPage(title: '古诗文斋'),
// 广告页
//            Offstage(
//              offstage: _hideAd,
//              child: ADPage((finished) {
//                setState(() {
//                  _hideAd = finished;
//                });
//              }),
//            )
          ],
        ),
      ),
    );
  }

  void createCollectionTable() async {
    PoemRecommendProvider provider = PoemRecommendProvider.singleton;
    await provider.open(DatabasePath);
  }
}
