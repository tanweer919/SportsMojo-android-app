import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Provider/MatchStatViewModel.dart';
import '../Provider/MatchEventViewModel.dart';
import 'package:sportsmojo/commons/custom_icons.dart';
import '../models/Score.dart';
import '../widgets/Stats.dart';
import '../services/GetItLocator.dart';
import 'package:provider/provider.dart';
import '../widgets/Scorers.dart';
import '../constants.dart';
import '../Provider/ThemeProvider.dart';

class MatchStatScreen extends StatefulWidget {
  final Score score;
  MatchStatScreen({this.score});

  @override
  _MatchStatScreenState createState() => _MatchStatScreenState();
}

class _MatchStatScreenState extends State<MatchStatScreen>
    with TickerProviderStateMixin {
  final MatchEventViewModel _matchEventViewModel =
      locator<MatchEventViewModel>();
  final MatchStatViewModel _matchStatViewModel = locator<MatchStatViewModel>();
  Animation<double> animation;
  AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    animation =
        Tween<double>(begin: 20.0, end: 0.0).animate(_animationController)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _animationController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              _animationController.forward();
            }
          });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
        builder: (context, themeModel, child) => SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: IconThemeData(
                      color: themeModel.appTheme == AppTheme.Light
                          ? Colors.black
                          : Colors.white),
                ),
                body: RefreshIndicator(
                  onRefresh: () async {},
                  child: (widget.score.status != 'NS')
                      ? SingleChildScrollView(
                          child: statSections(themeModel: themeModel),
                        )
                      : Container(
                          child: statSections(themeModel: themeModel),
                        ),
                ),
              ),
            ));
  }

  Widget statSections({ThemeProvider themeModel}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '${widget.score.competition} - ${convertDateTime(date_time: widget.score.date_time)}',
                  style: TextStyle(
                      fontSize: 12, color: Theme.of(context).primaryColorDark),
                ),
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: 40.0,
                    child: Text(
                      (widget.score.status == 'LV')
                          ? "${widget.score.minuteElapsed}'"
                          : "${widget.score.status}",
                      style: TextStyle(color: Colors.red, fontSize: widget.score.status == 'LV' ? 14 : 12),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  if (widget.score.status == 'LV')
                    Container(
                      width: animation.value,
                      height: 2.0,
                      color: Colors.red,
                    )
                ],
              )
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Container(
                          height: 60,
                          child: CachedNetworkImage(
                              imageUrl: widget.score.homeTeamLogo,
                              placeholder: (BuildContext context, String url) =>
                                  Icon(MyFlutterApp.football))),
                    ),
                    FittedBox(child: Text(widget.score.homeTeam), fit: BoxFit.fitWidth),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    (widget.score.minuteElapsed != null)
                        ? Text(
                            '${widget.score.homeScore} - ${widget.score.awayScore}',
                            style: TextStyle(fontSize: 30),
                          )
                        : Text(
                            'VS',
                            style: TextStyle(
                                fontSize: 18,
                                color: themeModel.appTheme == AppTheme.Light
                                    ? Color(0XAA000000)
                                    : Colors.white),
                          ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.2,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                          height: 60,
                          child: CachedNetworkImage(
                              imageUrl: widget.score.awayTeamLogo,
                              placeholder: (BuildContext context, String url) =>
                                  Icon(MyFlutterApp.football))),
                    ),
                    FittedBox(child: Text(widget.score.awayTeam), fit: BoxFit.fitWidth,)
                  ],
                ),
              )
            ],
          ),
          Divider(
            thickness: 0.7,
          ),
          (widget.score.status != 'NS')
              ? ChangeNotifierProvider(
                  create: (context) => _matchEventViewModel,
                  child: Scorer(
                    score: widget.score,
                  ),
                )
              : getScorer(),
          Divider(
            thickness: 0.7,
          ),
          (widget.score.status != 'NS')
              ? ChangeNotifierProvider(
                  create: (contet) => _matchStatViewModel,
                  child: Stats(
                    score: widget.score,
                  ),
                )
              : Expanded(
                  child: getStats(),
                )
        ],
      ),
    );
  }

  Widget getScorer() {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 80),
      child: Center(
        child: Text(
          'Match not started',
          style: TextStyle(
              fontSize: 18, color: Theme.of(context).primaryColorDark),
        ),
      ),
    );
  }

  Widget getStats() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    height: 25,
                    child: CachedNetworkImage(
                        imageUrl: widget.score.homeTeamLogo,
                        placeholder: (BuildContext context, String url) =>
                            Icon(MyFlutterApp.football))),
                Text('Team Stats'),
                Container(
                    height: 25,
                    child: CachedNetworkImage(
                        imageUrl: widget.score.awayTeamLogo,
                        placeholder: (BuildContext context, String url) =>
                            Icon(MyFlutterApp.football)))
              ],
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Match not started',
                  style: TextStyle(
                      fontSize: 22, color: Theme.of(context).primaryColorDark),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String convertDateTime({DateTime date_time}) {
    int dayDifferenceCount =
        dayDifference(date_time1: DateTime.now(), date_time2: date_time);
    if (dayDifferenceCount == 0) {
      return 'Today, ' + DateFormat('hh:mm aaa').format(widget.score.date_time);
    } else if (dayDifferenceCount == 1) {
      return 'Yesterday, ' +
          DateFormat('hh:mm aaa').format(widget.score.date_time);
    } else if (dayDifferenceCount == -1) {
      return 'Tomorrow, ' +
          DateFormat('hh:mm aaa').format(widget.score.date_time);
    } else {
      return DateFormat('E, d MMMM, hh:mm aaa').format(date_time);
    }
  }
}
