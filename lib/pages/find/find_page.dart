import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:wepoems_flutter/models/poem_tags.dart';
import 'package:wepoems_flutter/pages/find/search_controller.dart';

class FindPage extends StatefulWidget {
  @override
  _FindPageState createState() => _FindPageState();
}

class _FindPageState extends State<FindPage> {
  PoemSearchConditions _searchConditions;
  FocusNode _focusNode = FocusNode();
  TextEditingController _editingController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getSearchConditions();
  }

  Future<void> _getSearchConditions() async {
    String searchContentStr =
        await rootBundle.loadString("lib/sources/search_conditions.json");
    Map<String, dynamic> searchData =
        json.decode(searchContentStr) as Map<String, dynamic>;

    setState(() {
      _searchConditions = PoemSearchConditions.parseJSON(searchData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          SearchController(editingController: _editingController),
          SizedBox(
            height: 20,
          ),
          ListView.builder(
              itemCount: _searchConditions.hotsearchs.length,
              itemBuilder: (context, index) {
                PoemTagHotSearch search = _searchConditions.hotsearchs[index];
                List<String> hotKeyList = search.hotkeys;
                if (search.type == "poet") {
                  hotKeyList = hotKeyList.map<String>((item) {
                    return item.split("|").first;
                  }).toList();
                }
                return Column(
                  children: <Widget>[
                    Text(search.title),
                    Wrap(
                      children: hotKeyList.map<Widget>((item) {}),
                    )
                  ],
                );
              }),
        ],
      ),
    );
  }
}
