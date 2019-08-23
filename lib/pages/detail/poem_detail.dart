import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wepoems_flutter/models/poem_recommend.dart';
import 'package:wepoems_flutter/tools/dio_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:wepoems_flutter/models/poem_detail_model.dart';
import 'package:wepoems_flutter/pages/recommand/poem_cell.dart';
import 'package:wepoems_flutter/pages/detail/poem_anlyze_page.dart';
import 'package:wepoems_flutter/pages/detail/poem_author.dart';
import 'dart:math' as math;
import 'package:wepoems_flutter/pages/detail/poem_tag_page.dart';
import 'package:oktoast/oktoast.dart';
import 'dart:ui';
import 'dart:core';
import 'dart:io';
import 'package:wepoems_flutter/pages/detail/loading.dart';
import 'package:wepoems_flutter/pages/detail/error_retry_page.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wepoems_flutter/tools/bus_event.dart';
import 'package:share/share.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:wepoems_flutter/pages/detail/poem_show_snap.dart';

class PoemDetail extends StatefulWidget {
  PoemDetail({this.poemRecom});
  final PoemRecommend poemRecom;

  @override
  _PoemDetailState createState() => _PoemDetailState();
}

class _PoemDetailState extends State<PoemDetail> with TickerProviderStateMixin {
  PoemDetailModel _detailModel;
  List<Map<String, String>> _tabs = <Map<String, String>>[
    {"title": "译注"},
    {"title": "赏析"},
    {"title": "作者"}
  ];
  TabController _tabController;
//  PageController _pageController = PageController();
  PoemAnalyzeView _fanyisAnalyzeView;
  PoemAnalyzeView _shangxisAnalyzeView;
  PoemAuthorView _authorView;
  bool _collectionEnable = true;
  bool _isLoading = false;
  List<PoemRecommend> _poemRecoms = <PoemRecommend>[];
  List<PoemAnalyze> _analyzes = <PoemAnalyze>[];
  PoemAuthor _authorInfo = PoemAuthor();
  AudioPlayer _audioPlayer;
  AnimationController _animationController;
  AnimationStatusListener _animationStatusListener;
  GlobalKey captureImgKey = GlobalKey();
  bool _showSnapImg = false;
  String _snapImgPath = "";
  Image _snapImg;
  Size _snapImgSize;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    selectedCollection();
    _animationController =
        AnimationController(duration: Duration(seconds: 5), vsync: this);

    _animationStatusListener = (animationSatus) {
      if (animationSatus == AnimationStatus.completed) {
//        //动画从 controller.forward() 正向执行 结束时会回调此方法
//        print("status is completed");
      } else if (animationSatus == AnimationStatus.dismissed) {
        //动画从 controller.reverse() 反向执行 结束时会回调此方法
        print("status is dismissed");
      } else if (animationSatus == AnimationStatus.forward) {
        print("status is forward");
        //执行 controller.forward() 会回调此状态
      } else if (animationSatus == AnimationStatus.reverse) {
        //执行 controller.reverse() 会回调此状态
        print("status is reverse");
      }
    };

    _animationController.addStatusListener(_animationStatusListener);
  }

  void selectedCollection() async {
    if (widget.poemRecom.from == "collection") {
      _getPoemDetail();
      return;
    }

    PoemRecommendProvider provider = PoemRecommendProvider.singleton;
    if (!provider.db.isOpen) {
      await provider.open(DatabasePath);
    }
    provider
        .getPoemRecom(tableName: tableCollection, id: widget.poemRecom.idnew)
        .then((poem) {
          if (poem != null) {
            widget.poemRecom.isCollection = poem.isCollection;
            widget.poemRecom.nameStr = poem.nameStr;
            widget.poemRecom.author = poem.author;
            widget.poemRecom.chaodai = poem.chaodai;
            widget.poemRecom.cont = poem.cont;
            widget.poemRecom.tag = poem.tag;
            widget.poemRecom.from = "recommend";
            widget.poemRecom.dateTime = poem.dateTime;
          } else {
            widget.poemRecom.isCollection = false;
          }
          _detailModel.gushiwen.isCollection = widget.poemRecom.isCollection;
          _detailModel.gushiwen.from = widget.poemRecom.from;
          setState(() {});
        })
        .catchError((error) {})
        .whenComplete(() {
          _getPoemDetail();
        });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    _animationController.reset();
    _animationController.removeStatusListener(_animationStatusListener);
    _animationController.dispose();

    if (_audioPlayer != null) {
      if (_audioPlayer.state == AudioPlayerState.PLAYING) {
        _audioPlayer.release();
      }

      _audioPlayer.dispose();
    }

    super.dispose();
    DioManager.singleton.cancle();
    dismissAllToast();
  }

  void _scanRecord() async {
    if (_detailModel == null || widget.poemRecom.idnew.length == 0) {
      return;
    }
    PoemRecommendProvider provider = PoemRecommendProvider.singleton;
    await provider.open(DatabasePath);
    provider
        .getPoemRecom(tableName: tableRecords, id: widget.poemRecom.idnew)
        .then((poem) {
      if (poem != null) {
        provider.update(
            tableName: tableRecords, poemRecom: _detailModel.gushiwen);
      } else {
        provider.insert(
            tableName: tableRecords, poemRecom: _detailModel.gushiwen);
      }
    });
  }

  void _getPoemDetail() async {
    setState(() {
      _isLoading = true;
    });
    var postData = {"token": "gswapi", "id": widget.poemRecom.idnew};
    String path = widget.poemRecom.from == "mingju"
        ? "api/mingju/juv2.aspx"
        : "api/shiwen/shiwenv.aspx";

    DioManager.singleton.post(path: path, data: postData).then((response) {
      _detailModel = PoemDetailModel.parseJSON(response);
      _detailModel.gushiwen.from = widget.poemRecom.from;
      _detailModel.gushiwen.isCollection = widget.poemRecom.isCollection;

      _getAuthorMsg();
      _scanRecord();
      setState(() {});
    }).catchError((error) {
      if (error is DioError) {
        DioError dioError = error as DioError;
        if (dioError.type == DioErrorType.CONNECT_TIMEOUT) {
          showToast("网络连接超时，请检查网络", position: ToastPosition.center);
        }
      }

      if (error is FlutterError) {
        FlutterError flutterError = error as FlutterError;
      }
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _getAuthorMsg() async {
    if (_detailModel == null ||
        _detailModel.author == null ||
        _detailModel.author.idnew.length == 0) {
      _authorInfo = PoemAuthor(nameStr: widget.poemRecom.author);
      setState(() {
        _isLoading = false;
      });
      return;
    }
    var postData = {'token': 'gswapi', 'id': _detailModel.author.idnew};
    DioManager.singleton
        .post(path: "api/author/author2.aspx", data: postData)
        .then((response) {
          PoemAuthor authorTemp = PoemAuthor.parseJSON(response["tb_author"]);

          var tb_gushiwens = response["tb_gushiwens"] as Map<String, dynamic>;
          var gushiwens = tb_gushiwens["gushiwens"] as List<dynamic>;
          var gushiwensList = gushiwens.map<PoemRecommend>((poem) {
            return PoemRecommend.parseJSON(poem);
          }).toList();

          setState(() {
            _authorInfo = authorTemp;
            _poemRecoms = gushiwensList;
          });
        })
        .catchError((error) {})
        .whenComplete(() {
          setState(() {
            _isLoading = false;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        MaterialApp(
          theme: Theme.of(context),
          home: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  icon: Icon((Platform.isMacOS || Platform.isIOS)
                      ? Icons.arrow_back_ios
                      : Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              actions: <Widget>[
                radioButton(),
                collectionButtonAction(),
                shareButtonAction(),
                snaptButtonAction()
              ],
            ),
            body: Offstage(
              offstage: _detailModel == null,
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    MediaQuery.of(context).padding.left,
                    0,
                    MediaQuery.of(context).padding.right,
                    MediaQuery.of(context).padding.bottom),
                color: Colors.white,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: poemHeader(),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      floating: true,
                      delegate: _SliverAppBarDelegate(
                        minHeight: 55,
                        maxHeight: 55,
                        child: poemAnalyzeTabBar(),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: poemAnalyzePageView(index),
                          );
                        },
                        childCount: analyzesCount(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        LoadingIndicator(isLoading: _isLoading),
        RetryPage(
          offstage: _detailModel != null || _isLoading,
          onTap: () {
            _getPoemDetail();
          },
        ),
      ],
    );
  }

  IconButton snaptButtonAction() {
    return IconButton(
        icon: Icon(Icons.content_cut),
        onPressed: () {
          _capturePng().then((_) {
            if (_snapImg == null) {
              return;
            }
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (BuildContext context, Animation animation,
                    Animation secondaryAnimation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ShowSnapImg(
                      snapImg: _snapImg,
                      snapImgSize: _snapImgSize,
                    ),
                  );
                },
              ),
            );
          }).catchError((error) {});
        });
  }

  Future _capturePng() async {
    if (_snapImg != null) {
      return;
    }

    if (_detailModel == null) {
      return;
    }
    try {
      RenderRepaintBoundary boundary =
          captureImgKey.currentContext.findRenderObject();
//      boundary.toImage(pixelRatio: 3.0).then((image) {
//        image.toByteData(format: ImageByteFormat.png).then((byteData) {
//          Uint8List pngBytes = byteData.buffer.asUint8List();
//          _snapImg = Image.memory(pngBytes);
//        });
//      });
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      _snapImg = Image.memory(pngBytes);
      _snapImgSize = Size(image.width.toDouble(), image.height.toDouble());
      setState(() {});
//      print("width:" +
//          image.width.toString() +
//          " " +
//          "height:" +
//          image.height.toString());
//      Directory tempDirectory = await getTemporaryDirectory();
//      String imgPath =
//          tempDirectory.path + '/' + _detailModel.gushiwen.idnew + ".png";
//      _snapImgPath = imgPath;
//      File imgFile = File(imgPath);
//      bool fileExist = await imgFile.exists();
//      if (!fileExist) {
//        imgFile.writeAsBytesSync(pngBytes);
//      }

    } catch (e) {
      print(e);
    }
  }

  IconButton shareButtonAction() {
    return IconButton(
        icon: Icon(
          Icons.share,
          color: Colors.white,
        ),
        onPressed: () {
          String poemTitle = _detailModel.gushiwen.nameStr;
          String poemtDynastyAndAuthor = _detailModel.gushiwen.chaodai +
              "/" +
              _detailModel.gushiwen.author;
          String poemCont = _detailModel.gushiwen.cont;
          Share.share("poemConten");
        });
  }

  IconButton collectionButtonAction() {
    return IconButton(
      icon: Icon(
          (_detailModel != null && _detailModel.gushiwen.isCollection)
              ? Icons.star
              : Icons.star_border,
          color: Colors.white),
      onPressed: () {
        dismissAllToast();

        if (_detailModel == null || widget.poemRecom.idnew.length == 0) {
          return;
        }

        if (_collectionEnable == false) {
          showToast("您的操作太频繁了，稍等！", position: ToastPosition.center);
          return;
        }

        PoemRecommendProvider provider = PoemRecommendProvider.singleton;
        provider.open(DatabasePath).then((dyanmic) {
          _collectionEnable = false;
          _detailModel.gushiwen.isCollection =
              !_detailModel.gushiwen.isCollection;
          widget.poemRecom.isCollection = !widget.poemRecom.isCollection;
          if (_detailModel.gushiwen.isCollection) {
            provider
                .insert(
                    tableName: tableCollection,
                    poemRecom: _detailModel.gushiwen)
                .then((dynamic) {
              showToast("收藏成功", position: ToastPosition.center);
              setState(() {});
            }).catchError((error) {
              showToast("收藏失败", position: ToastPosition.center);
            }).whenComplete(() {
              _collectionEnable = true;
              if (_detailModel.gushiwen.from == "collection" &&
                  _detailModel.gushiwen.isCollection) {
                bus.emit("kCollectionAdd", widget.poemRecom);
              }
            });
          } else {
            Future.wait([
              deleteCollectionSource(provider),
              updateRecordSource(provider)
            ]).then((dynamic) {
              showToast("取消收藏成功", position: ToastPosition.center);
              setState(() {});
            }).catchError((error) {
              showToast("取消收藏失败", position: ToastPosition.center);
            }).whenComplete(() {
              _collectionEnable = true;
              if (_detailModel.gushiwen.from == "collection" &&
                  _detailModel.gushiwen.isCollection == false) {
                bus.emit("kCollectionCancle", _detailModel.gushiwen.idnew);
              }
            });
          }
        });
      },
    );
  }

  Future deleteCollectionSource(PoemRecommendProvider provider) async {
    provider.delete(
        tableName: tableCollection, id: _detailModel.gushiwen.idnew);
  }

  Future updateRecordSource(PoemRecommendProvider provider) async {
    provider.update(tableName: tableRecords, poemRecom: widget.poemRecom);
  }

  RotationTransition radioButton() {
    return RotationTransition(
      alignment: Alignment.center,
      turns: _animationController,
      child: IconButton(
          icon: Icon(
            Icons.headset,
            color: (_detailModel == null ||
                    _detailModel.gushiwen.langsongAuthorPY.length == 0)
                ? Colors.transparent
                : Colors.white,
          ),
          onPressed: () {
            if (_audioPlayer == null) {
              _audioPlayer = AudioPlayer(mode: PlayerMode.LOW_LATENCY);
              _audioPlayer.onPlayerStateChanged
                  .listen((AudioPlayerState status) {
                status == AudioPlayerState.PLAYING
                    ? _animationController.repeat()
                    : _animationController.reset();
              });

              _audioPlayer.onPlayerError.listen((String event) {
                _audioPlayer.release();
                _audioPlayer.dispose();
                _audioPlayer = null;
                showToast("音频加载失败!");
              });
            }

            if (_audioPlayer.state == AudioPlayerState.COMPLETED ||
                _audioPlayer.state == null) {
              String pyName = _detailModel.gushiwen.langsongAuthorPY;
              String pyid = _detailModel.gushiwen.idnew;
              _audioPlayer
                  .play("https://song.gushiwen.org/song/$pyName/$pyid.mp3");
            } else if (_audioPlayer.state == AudioPlayerState.PAUSED) {
              _audioPlayer.resume();
            } else if (_audioPlayer.state == AudioPlayerState.PLAYING) {
              _audioPlayer.pause();
            }
          }),
    );
  }

  int analyzesCount() {
    switch (_tabController.index) {
      case 0:
        return _detailModel == null
            ? 0
            : (_detailModel.fanyis.length == 0
                ? 1
                : _detailModel.fanyis.length);
      case 1:
        return _detailModel == null
            ? 0
            : (_detailModel.shagnxis.length == 0
                ? 1
                : _detailModel.shagnxis.length);
      case 2:
        return 1;
    }
  }

  Container poemHeader() {
    if (_detailModel == null && widget.poemRecom.from != "recommend") {
      return Container();
    }

    PoemRecommend source =
        _detailModel == null ? widget.poemRecom : _detailModel.gushiwen;

    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  RepaintBoundary(
                    key: captureImgKey,
                    child: PoemCell(poem: source),
                  ),
                  Hero(
                    tag: "hero",
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: _snapImg,
                    ),
                  ),
                ],
              ),
              PoemTagPage(
                tagStr: source.tag,
                pushContext: context,
              )
            ],
          ),
        ],
      ),
    );
  }

  Container poemAnalyzeTabBar() {
    return Container(
      color: Colors.white,
      alignment: Alignment.centerLeft,
      child: Column(
        children: <Widget>[
          TabBar(
            isScrollable: true,
            controller: _tabController,
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.black45,
            tabs: _tabs.map<Tab>((tab) {
              int index = _tabs.indexOf(tab);
              bool isCurrentTab = _tabController.index == index;
              return Tab(
                child: Text(tab["title"]),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget sliverPoemAnalyzeCell(List<PoemAnalyze> analyze, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            analyze[index].nameStr,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
        ),
        Html(
          data: analyze[index].cont,
        )
      ],
    );
  }

  Widget poemAnalyzePageView(int index) {
    switch (_tabController.index) {
      case 0:
        if (_fanyisAnalyzeView == null) {
          _fanyisAnalyzeView = PoemAnalyzeView(
              analyzes: _detailModel.fanyis,
              index: index,
              pageType: AnalyzePageType.AnalyzePageFanyi);
        }
        return _fanyisAnalyzeView;
      case 1:
        if (_shangxisAnalyzeView == null) {
          _shangxisAnalyzeView = PoemAnalyzeView(
            analyzes: _detailModel.shagnxis,
            index: index,
            pageType: AnalyzePageType.AnalyzePageShangxi,
          );
        }
        return _shangxisAnalyzeView;
      default:
        if (_authorView == null) {
          _authorView = PoemAuthorView(
            poemRecoms: _poemRecoms,
            analyzes: _analyzes,
            authorInfo: _authorInfo,
            pushContext: context,
          );
        }
        return _authorView;
    }
  }
}

// 常驻表头代理
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
