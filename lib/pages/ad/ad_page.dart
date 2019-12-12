import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

typedef void ADPageCallback(bool finished);

class ADPage extends StatefulWidget {
  ADPage(this.callback);

  final ADPageCallback callback;

  @override
  _ADPageState createState() => _ADPageState();
}

class _ADPageState extends State<ADPage> {
  Timer _counterTimer;
  bool _installed = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _counterTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timer.tick == 5) {
        widget.callback(true);
        _counterTimer.cancel();
      }
    });

    fistInstallPreference();
  }

  void fistInstallPreference() async {
    await SharedPreferences.getInstance().then((preference) {
      if (preference.getBool("kInstalled") == null) {
        _installed = false;
        _counterTimer.cancel();
        preference.setBool("kInstalled", true);
      } else {
        _installed = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Stack(
        children: <Widget>[
          Swiper(
            autoplay: true,
            itemCount: _installed ? 1 : 3,
            pagination: SwiperPagination(
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom == 0
                      ? 20
                      : MediaQuery.of(context).padding.bottom),
            ),
            itemBuilder: (context, index) {
              int page = index + 1;
              String imgName =
                  "lib/images/welcome_0" + page.toString() + ".png";
              return Container(
                child: Image.asset(imgName),
              );
            },
          ),
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: 1,
                  height: 1,
                ),
                GestureDetector(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0.0, 20.0, 0),
                    child: Text(
                      "跳过",
                      style: TextStyle(
                          fontSize: 15.0,
                          color: Colors.white,
                          backgroundColor: Colors.black12,
                          decoration: TextDecoration.none),
                    ),
                  ),
                  onTap: () {
                    widget.callback(true);
                  },
                )
              ],
            ),
            top: true,
            right: true,
          )
        ],
      ),
    );
  }
}
