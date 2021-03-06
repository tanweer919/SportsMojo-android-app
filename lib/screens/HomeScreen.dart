import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import '../commons/ScoreCard.dart';
import '../models/Score.dart';
import '../commons/BottomNavbar.dart';
import '../commons/NewsCard.dart';
import '../models/News.dart';
import 'package:pk_skeleton/pk_skeleton.dart';
import '../services/FlushbarHelper.dart';
import '../Provider/HomeViewModel.dart';
import '../services/GetItLocator.dart';
import '../Provider/AppProvider.dart';
import '../Provider/ThemeProvider.dart';
import '../services/tutorial.dart';
import '../commons/GlobalKeys.dart';
import '../services/LocalStorage.dart';
class HomeScreen extends StatefulWidget {
  @override
  final Map<String, dynamic> message;
  bool showTutorial;
  HomeScreen({this.message, this.showTutorial});
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _pageController = PageController(initialPage: 0);
  String teamName;
  @override
  void initState() {
    final initialState = Provider.of<AppProvider>(context, listen: false);
    final tutorial = Tutorial();
    tutorial.initTargets(GlobalKeys.globalKeys);
    if (initialState.newsList == null) {
      initialState.loadAllNews();
    }
    if (initialState.favouriteNewsList == null) {
      initialState.loadFavouriteNews();
    }
    if (initialState.favouriteTeamScores == null) {
      initialState.loadFavouriteScores().then((value) {
        LocalStorage.getString('tutorialShown').then((value) {
          if (widget.showTutorial) {
            tutorial.showAfterLayout(context);
          }
        });
      });
    }
    if (initialState.leagueWiseScores == null) {
      initialState.loadLeagueWiseScores();
    }
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAlert();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  HomeViewModel _viewModel = locator<HomeViewModel>();

  @override
  Widget build(BuildContext context) {
    final AppProvider appProvider = Provider.of<AppProvider>(context);
    return Scaffold(
        bottomNavigationBar: BottomNavbar(),
        body: Consumer<ThemeProvider>(
          builder: (context, themeModel, child) =>
              ChangeNotifierProvider<HomeViewModel>(
            create: (context) => _viewModel,
            child: Consumer<HomeViewModel>(
              builder: (context, model, child) => SafeArea(
                child: RefreshIndicator(
                  onRefresh: () async {
                    EasyLoading.instance
                      ..displayDuration = const Duration(milliseconds: 2000)
                      ..indicatorType = EasyLoadingIndicatorType.chasingDots
                      ..loadingStyle = EasyLoadingStyle.custom
                      ..indicatorSize = 45.0
                      ..radius = 10.0
                      ..backgroundColor = Theme.of(context).primaryColor
                      ..indicatorColor = Colors.white
                      ..maskColor = Colors.blue.withOpacity(0.5)
                      ..progressColor = Theme.of(context).primaryColor
                      ..textColor = Colors.white;
                    EasyLoading.show(status: 'Fetching latest content');
                    await _handleRefresh(appProvider: appProvider);
                    EasyLoading.dismiss();
                  },
                  child: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Flexible(
                              fit: FlexFit.loose,
                              child: carousel(
                                  model: model, appProvider: appProvider)),
                          appProvider.favouriteTeamScores != null
                              ? UpcomingMatchesSection(appProvider: appProvider)
                              : themeModel.appTheme == AppTheme.Light
                                  ? PKCardSkeleton(
                                      isCircularImage: true,
                                      isBottomLinesActive: true,
                                    )
                                  : PKDarkCardSkeleton(
                                      isCircularImage: true,
                                      isBottomLinesActive: true,
                                    ),
                          NewsSection(
                              model: model,
                              themeModel: themeModel,
                              appProvider: appProvider)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  Widget UpcomingMatchesSection({AppProvider appProvider}) {
    final List<Score> matches = appProvider.favouriteTeamScores;
    Score score;
    String caption;
    final Score liveMatch =
        matches.firstWhere((score) => score.status == "LV", orElse: () => null);
    if (liveMatch == null) {
      final int index = matches.indexWhere((score) => score.status == "FT");
      final Score latestScore = matches[index];
      if (index > 0) {
        final Score nextScore = matches[index - 1];
        if (nextScore.date_time.difference(DateTime.now()).inSeconds <
            DateTime.now().difference(latestScore.date_time).inSeconds) {
          if (nextScore.date_time.difference(DateTime.now()).inSeconds < 0) {
            score = nextScore;
            caption = 'Latest Match';
          } else {
            score = nextScore;
            caption = 'Upcoming Match';
          }
        } else {
          score = latestScore;
          caption = 'Latest Match';
        }
      } else {
        score = latestScore;
        caption = 'Latest Match';
      }
    } else {
      score = liveMatch;
      caption = 'Live Match';
    }
    return Padding(
      key: widget.showTutorial ? GlobalKeys.matchCardKey : null,
      padding: const EdgeInsets.all(8.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                caption,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
            ScoreCard(
              score: score,
            )
          ]),
    );
  }

  Widget NewsSection(
      {HomeViewModel model,
      ThemeProvider themeModel,
      AppProvider appProvider}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        key: widget.showTutorial ? GlobalKeys.allNewsCardKey : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Latest News',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                textAlign: TextAlign.left,
              ),
            ),
            appProvider.newsList != null
                ? ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: appProvider.newsList.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider();
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return NewsCard(
                        index: index,
                        news: appProvider.newsList[index],
                      );
                    })
                : ListView.builder(
                    itemCount: 5,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return themeModel.appTheme == AppTheme.Light
                          ? PKCardSkeleton(
                              isCircularImage: true,
                              isBottomLinesActive: true,
                            )
                          : PKDarkCardSkeleton(
                              isCircularImage: true,
                              isBottomLinesActive: true,
                            );
                    })
          ],
        ),
      ),
    );
  }

  Widget carousel({HomeViewModel model, AppProvider appProvider}) {
    List<News> favouriteNewsList = appProvider.favouriteNewsList;
    List<News> allNewsList = appProvider.newsList;
    int totalCount;
    int circleCount;
    if (favouriteNewsList != null) {
      totalCount = favouriteNewsList.length > 5 ? 5 : favouriteNewsList.length;
      circleCount = totalCount == 0 ? 5 : totalCount;
    }
    return Container(
        height: MediaQuery.of(context).size.height * 0.35,
        key: widget.showTutorial ? GlobalKeys.carouselKey : null,
        child: favouriteNewsList != null
            ? Stack(
          alignment: Alignment.bottomLeft,
                children: <Widget>[
                  PageView(
                    controller: _pageController,
                    children: (totalCount != 0)
                        ? <Widget>[
                            for (int i = 0; i < totalCount; i++)
                              InkWell(
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed('/newsarticle', arguments: {
                                    'index': i + 100,
                                    'news': favouriteNewsList[i]
                                  });
                                },
                                child: Stack(
                                  alignment: Alignment.bottomLeft,
                                  children: <Widget>[
                                    Container(
                                      child: CachedNetworkImage(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.35,
                                        imageUrl: favouriteNewsList[i].imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (BuildContext context,
                                                String url) =>
                                            Image.asset(
                                          'assets/images/news_default.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      color: Colors.black.withOpacity(0.4),
                                      padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02,
                                          left: 12.0,
                                          right: 12.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Flexible(
                                            child: Text(
                                              favouriteNewsList[i].title,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 4.0),
                                                child: Text(
                                                  favouriteNewsList[i].source,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          Colors.amberAccent),
                                                ),
                                              ),
                                              Text(
                                                convertDateTime(
                                                    dateTime:
                                                        favouriteNewsList[i]
                                                            .publishedAt),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.amberAccent),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                          ]
                        : <Widget>[
                            for (int i = 0; i < 5; i++)
                              InkWell(
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed('/newsarticle', arguments: {
                                    'index': i + 100,
                                    'news': allNewsList[i]
                                  });
                                },
                                child: Stack(
                                  alignment: Alignment.bottomLeft,
                                  children: <Widget>[
                                    Container(
                                      child: CachedNetworkImage(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.35,
                                        imageUrl: allNewsList[i].imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (BuildContext context,
                                                String url) =>
                                            Image.asset(
                                          'assets/images/news_default.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      color: Colors.black.withOpacity(0.4),
                                      padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02,
                                          left: 12.0,
                                          right: 12.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Flexible(
                                            child: Text(
                                              allNewsList[i].title,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 4.0),
                                                child: Text(
                                                  allNewsList[i].source,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          Colors.amberAccent),
                                                ),
                                              ),
                                              Text(
                                                convertDateTime(
                                                    dateTime: allNewsList[i]
                                                        .publishedAt),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.amberAccent),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                          ],
                    onPageChanged: (int index) {
                      model.carouselIndex = index;
                    },
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.02,
                      color: Colors.black.withOpacity(0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          for (int i = 0; i < circleCount; i++)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.0),
                              child: InkWell(
                                onTap: () {
                                  _pageController.animateToPage(i,
                                      duration: Duration(milliseconds: 200),
                                      curve: Curves.easeIn);
                                },
                                child: Container(
                                  height: 10,
                                  width: 10,
                                  decoration: BoxDecoration(
                                      color: model.carouselIndex == i
                                          ? Theme.of(context).primaryColor
                                          : Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                  )
                ],
              )
            : PageView(
                controller: _pageController,
                children: <Widget>[
                  for (int i = 0; i < 5; i++)
                    Container(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: Image.asset(
                        'assets/images/news_default.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
                onPageChanged: (int index) {
                  model.carouselIndex = index;
                },
              ));
  }

  String convertDateTime({DateTime dateTime}) {
    DateTime now = DateTime.now();
    int diffMin = now.difference(dateTime).inMinutes;
    int diffHr = now.difference(dateTime).inHours;
    int diffDay = now.difference(dateTime).inDays;

    if (diffMin < 60) {
      return '$diffMin mins';
    } else if (diffMin < 1440) {
      return '$diffHr hrs';
    } else {
      return '$diffDay days';
    }
  }

  void showAlert() {
    if (widget.message != null) {
      FlushHelper.flushbarAlert(
          context: context,
          title: widget.message['title'],
          message: widget.message['content'],
          seconds: 3);
    }
  }

  Future<void> _handleRefresh({AppProvider appProvider}) async {
    await appProvider.loadAllNews();
    await appProvider.loadFavouriteNews();
    await appProvider.loadFavouriteScores();
    await appProvider.loadLeagueWiseScores();
  }
}
