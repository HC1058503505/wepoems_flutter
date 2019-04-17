import 'package:flutter/material.dart';

class SearchController extends StatelessWidget {
  SearchController({this.editingController});
  final TextEditingController editingController;
  FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 15, 0),
      decoration: BoxDecoration(
          border: Border.all(
              color: Colors.black26, width: 1, style: BorderStyle.solid),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: TextField(
        focusNode: _focusNode,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(Icons.search),
          labelText: "请输入关键字",
          labelStyle: TextStyle(color: Colors.black26, fontSize: 20),
        ),
        controller: editingController,
        onEditingComplete: () {
          print("Complete");
        },
        onSubmitted: (searchCont) {
          print(searchCont);
          _focusNode.unfocus();
        },
        textInputAction: TextInputAction.done,
      ),
    );
  }
}
