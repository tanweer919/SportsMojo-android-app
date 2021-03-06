import 'package:sportsmojo/models/Score.dart';
import 'package:flutter/material.dart';

//Leagues and its corresponding id and logo
final Map<String, dynamic> leagues = {
  "Bundesliga": {
    "id": 78,
    "logo": "https://media.api-sports.io/football/leagues/78.png"
  },
  "Eredivisie" : {
    "id": 88,
    "logo": "https://media.api-sports.io/football/leagues/88.png"
  },
  "Indian Super League": {
    "id": 323,
    "logo": "https://media.api-sports.io/football/leagues/323.png"
  },
  "I-League": {
    "id": 324,
    "logo": "https://media.api-sports.io/football/leagues/324.png"
  },
  "La Liga": {
    "id":140,
    "logo": "https://media.api-sports.io/football/leagues/140.png"
  },
  "Ligue 1": {
    "id": 61,
    "logo": "https://media.api-sports.io/football/leagues/61.png"
  },
  "Premier League": {
    "id": 39,
    "logo": "https://media.api-sports.io/football/leagues/39.png"
  },
  "Primeira Liga(Portugal)": {
    "id": 94,
    "logo": "https://media.api-sports.io/football/leagues/94.png"
  },
  "Seria A": {
    "id": 135,
    "logo": "https://media.api-sports.io/football/leagues/135.png"
  },
  "UEFA Champions League" : {
    "id": 2,
    "logo": "https://media.api-sports.io/football/leagues/2.png"
  },
  "UEFA Europa League" : {
    "id": 3,
    "logo": "https://media.api-sports.io/football/leagues/3.png"
  },
};


///Get difference between two dates in days
int dayDifference({DateTime date_time1, DateTime date_time2}) {
  final date1 = DateTime(date_time1.year, date_time1.month, date_time1.day);
  final date2 = DateTime(date_time2.year, date_time2.month, date_time2.day);
  return date1.difference(date2).inDays;
}

//
List<Score> filterScores({List<Score> scores, DateTime after, DateTime before}) {
  return scores.where((score) => dayDifference(date_time1: score.date_time, date_time2: after) >=0 && dayDifference(date_time1: score.date_time, date_time2: before) <= 0).toList();
}

//Get first and last date of the matches in current league
Map<String, DateTime> getFirstAndLastDate(List<Score> scores) {
  Map<String, DateTime> dates = {};
  final firstDate = scores.last.date_time;
  dates["firstDate"] = DateTime(firstDate.year, firstDate.month, firstDate.day);
  final lastDate = scores[0].date_time;
  dates["lastDate"] = DateTime(lastDate.year, lastDate.month, lastDate.day);
  return dates;
}

//Get List of DropdownMenuItem for league dropdown
List<DropdownMenuItem> getLeagueItems() {
  return leagues.entries
      .map<DropdownMenuItem<String>>((entry) => DropdownMenuItem<String>(
    value: entry.key,
    child: Text(entry.key),
  ))
      .toList();
}