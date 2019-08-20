import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  LoadingIndicator({this.isLoading});
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: !isLoading,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}


class LoadingActivityIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CupertinoActivityIndicator(),
          Text("加载更多。。。", textAlign: TextAlign.center,)
        ],
      ),
    );
  }
}