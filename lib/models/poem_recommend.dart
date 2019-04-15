class PoemRecommend {
  int id = 0; // id
  String idnew = ""; // 诗词新id
  String nameStr = ""; // 诗名
  String author = ""; // 作者
  String chaodai = ""; // 朝代
  String cont = ""; // 诗词内容
  String tag = ""; // 标签

  PoemRecommend.parseJSON(Map<String, dynamic> poem) {
    id = poem["id"] as int;
    idnew = poem["idnew"].toString();
    nameStr = poem["nameStr"].toString();
    author = poem["author"].toString();
    chaodai = poem["chaodai"].toString();
    cont = poem["cont"]
        .toString()
        .replaceAll(RegExp("<(\/)?p>"), "")
        .replaceAll(RegExp("<br \/>"), "\n")
        .replaceAll(RegExp("[\(|（].*[\)|）]"), "")
        .replaceAll(RegExp("<span.*span>"), "").trim();
    tag = poem["tag"].toString();
  }
}
