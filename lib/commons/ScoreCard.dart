import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/Score.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'custom_icons.dart';
import '../constants.dart';
import 'GlobalKeys.dart';

class ScoreCard extends StatefulWidget {
  final Score score;
  ScoreCard({this.score});

  @override
  _ScoreCardState createState() => _ScoreCardState();
}

class _ScoreCardState extends State<ScoreCard> with TickerProviderStateMixin {
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

  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .pushNamed('/matchstat', arguments: {'score': widget.score});
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '${widget.score.competition} - ${convertDateTime(date_time: widget.score.date_time)}',
                      style: TextStyle(
                          fontSize: (widget.score.competition.startsWith('UEFA')) ? 11: 12,
                          color: Theme.of(context).primaryColorDark),
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
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: widget.score.status == 'LV' ? 14 : 12),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
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
                                    placeholder:
                                        (BuildContext context, String url) =>
                                            Icon(MyFlutterApp.football))),
                          ),
                          FittedBox(
                            child: Text(widget.score.homeTeam),
                            fit: BoxFit.fitWidth,
                          )
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
                                      color:
                                          Theme.of(context).primaryColorDark),
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
                                    placeholder:
                                        (BuildContext context, String url) =>
                                            Icon(MyFlutterApp.football))),
                          ),
                          FittedBox(
                            child: Text(widget.score.awayTeam),
                            fit: BoxFit.fitWidth,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
//                                if (_cardExpanded[index])
//                                  scorers(),
            ],
          ),
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
