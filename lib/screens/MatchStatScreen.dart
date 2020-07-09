import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Provider/MatchEventViewModel.dart';
import 'package:sportsmojo/commons/custom_icons.dart';
import '../models/Score.dart';
import '../widgets/Stats.dart';
import '../services/GetItLocator.dart';
import 'package:provider/provider.dart';
import '../widgets/Scorers.dart';

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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        '${widget.score.competition} - ${DateFormat('E, d MMMM, hh:mm aaa').format(widget.score.date_time)}',
                        style:
                            TextStyle(fontSize: 12, color: Color(0X8A000000)),
                      ),
                    ),
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 20.0,
                          child: Text(
                            (widget.score.minuteElapsed != null &&
                                    widget.score.minuteElapsed != 90 &&
                                    widget.score.minuteElapsed != 120)
                                ? "${widget.score.minuteElapsed}'"
                                : "${widget.score.status}",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        if (widget.score.minuteElapsed != null &&
                            widget.score.minuteElapsed != 90 &&
                            widget.score.minuteElapsed != 120)
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
                    Column(
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
                        FittedBox(child: Text(widget.score.homeTeam)),
                      ],
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
                                      fontSize: 18, color: Color(0XAA000000)),
                                ),
                        ],
                      ),
                    ),
                    Column(
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
                        FittedBox(child: Text(widget.score.awayTeam))
                      ],
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
                    ? Stats(
                        score: widget.score,
                      )
                    : getStats()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getScorer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: 50, minWidth: MediaQuery.of(context).size.width * 0.4),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Container()],
            ),
          ),
        ),
        Container(
          height: 10,
          child: Icon(
            MyFlutterApp.football,
            color: Color(0XAA000000),
            size: 20,
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: 50, minWidth: MediaQuery.of(context).size.width * 0.4),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [Container()],
            ),
          ),
        )
      ],
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
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'N/A',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Shots',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'N/A',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'N/A',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Shots on target',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'N/A',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'N/A',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Possession',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'N/A',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'N/A',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Total Passes',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'N/A',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'N/A',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Accurate Passes',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'N/A',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'N/A',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Fouls',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'N/A',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'N/A',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Yellow Cards',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'N/A',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'N/A',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Red Cards',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'N/A',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'N/A',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Offsides',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'N/A',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'N/A',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Corners',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'N/A',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'N/A',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Saves',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'N/A',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
