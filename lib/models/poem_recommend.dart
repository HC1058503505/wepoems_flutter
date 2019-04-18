class PoemRecommend {
  int id = 0; // id
  String idnew = ""; // 诗词新id
  String nameStr = ""; // 诗名
  String author = ""; // 作者
  String chaodai = ""; // 朝代
  String cont = ""; // 诗词内容
  String tag = ""; // 标签

  PoemRecommend({this.id, this.idnew, this.nameStr, this.author, this.chaodai, this.cont, this.tag});

  PoemRecommend.parseJSON(Map<String, dynamic> poem) {
    id = poem["id"] as int;
    idnew = poem["idnew"].toString().replaceAll(RegExp("null"), "");
    nameStr = poem["nameStr"].toString().replaceAll(RegExp("null"), "");
    author = poem["author"].toString().replaceAll(RegExp("null"), "");
    chaodai = poem["chaodai"].toString().replaceAll(RegExp("null"), "");
    cont = poem["cont"]
        .toString()
        .replaceAll(RegExp("null"), "")
        .replaceAll(RegExp("<(\/)?p>"), "")
        .replaceAll(RegExp("<br \/>"), "\n")
        .replaceAll(RegExp("[\(|（].*[\)|）]"), "")
        .replaceAll(RegExp("<span.*span>"), "").trim();
    tag = poem["tag"].toString().replaceAll(RegExp("null"), "");
  }
}
