import 'package:flutter/material.dart';
import 'package:sportsmojo/models/Score.dart';
import 'package:sportsmojo/services/ScoreService.dart';
import '../services/NewsService.dart';
import '../services/LocalStorage.dart';
import '../services/GetItLocator.dart';
import '../models/News.dart';
import '../constants.dart';
import '../models/LeagueTable.dart';
import '../services/LeagueTableService.dart';
import '../services/TopScorerService.dart';
import '../models/Player.dart';
import '../models/User.dart';
import '../services/RemoteConfigService.dart';

class AppProvider extends ChangeNotifier {
  AppProvider(this._navbarIndex, this._selectedLeague, this._notificationEnabled, this._startDate, this._endDate, this._currentUser);
  int _navbarIndex;
  List<News> _newsList;
  List<News> _favouriteNewsList;
  List<Score> _leagueWiseScores;
  List<LeagueTableEntry> _leagueTableEntries;
  DateTime _startDate;
  DateTime _endDate;
  List<Score> _favouriteTeamScores;
  String _selectedLeague;
  List<Player> _topScorers;
  User _currentUser;
  bool _notificationEnabled;

  NewsService _newsService = locator<NewsService>();
  ScoreService _scoreService = locator<ScoreService>();
  LeagueTableService _leagueTableService = locator<LeagueTableService>();
  TopScorerService _topScorerService = locator<TopScorerService>();

  int get navbarIndex => _navbarIndex;

  String get selectedLeague => _selectedLeague;

  List<News> get newsList => _newsList;
  List<News> get favouriteNewsList => _favouriteNewsList;
  List<Score> get favouriteTeamScores => _favouriteTeamScores;
  List<Score> get leagueWiseScores => _leagueWiseScores;

  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  List<LeagueTableEntry> get leagueTableEntries => _leagueTableEntries;
  List<Player> get topScorers => _topScorers;
  User get currentUser => _currentUser;

  bool get notificationEnabled => _notificationEnabled;

  void set selectedLeague(String league) {
    _selectedLeague = league;
    notifyListeners();
  }

  void set navbarIndex(int index) {
    _navbarIndex = index;
    notifyListeners();
  }

  void set newsList(List<News> news) {
    _newsList = news;
    notifyListeners();
  }

  void set favouriteNewsList(List<News> news) {
    if(news != null) {
      _favouriteNewsList = news.sublist(0, 4);
    }
    else {
      _favouriteNewsList = news;
    }
    notifyListeners();
  }

  void set favouriteTeamScores(List<Score> scores) {
    _favouriteTeamScores = scores;
    notifyListeners();
  }

  void set leagueWiseScores(List<Score> scores) {
    _leagueWiseScores = scores;
    notifyListeners();
  }

  void set startDate(DateTime date) {
    _startDate = date;
    notifyListeners();
  }

  void set endDate(DateTime date) {
    _endDate = date;
    notifyListeners();
  }

  void set currentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void set leagueTableEntries(List<LeagueTableEntry> newLeagueTable) {
    _leagueTableEntries = newLeagueTable;
    notifyListeners();
  }

  void set topScorers(List<Player> scorers) {
    _topScorers = scorers;
    notifyListeners();
  }

  void set notificationEnabled(bool value) {
    _notificationEnabled = value;
    notifyListeners();
  }

  Future<void> loadAllNews() async{
    String placeholderUrl = 'https://res.cloudinary.com/doy9hqxr1/image/upload/q_70/v1596572656/Football-Class-Cover-Page_sjrsaq.jpg';
    List<News> allNews = await _newsService.fetchNews('european football');
    List<News> allNewsFirst = allNews.where((news) => news.imageUrl != placeholderUrl).toList();
    List<News> allNewsSecond = allNews.where((news) => news.imageUrl == placeholderUrl).toList();
    _newsList = allNewsFirst + allNewsSecond;
    notifyListeners();
  }

  Future<void> loadFavouriteNews() async {
    String placeholderUrl = 'https://res.cloudinary.com/doy9hqxr1/image/upload/q_70/v1596572656/Football-Class-Cover-Page_sjrsaq.jpg';
    String teamName = await LocalStorage.getString('teamName');
    List<News> favouriteNews = await  _newsService.fetchNews(teamName);;
    List<News> favouriteNewsFirst = favouriteNews.where((news) => news.imageUrl != placeholderUrl).toList();
    List<News> favouriteNewsSecond = favouriteNews.where((news) => news.imageUrl == placeholderUrl).toList();
    _favouriteNewsList = favouriteNewsFirst + favouriteNewsSecond;
    notifyListeners();
  }

  Future<void> loadLeagueWiseScores({String leagueName}) async {
    if(leagueName == null) {
      String storedLeagueId = await LocalStorage.getString('leagueId');
      _leagueWiseScores = await _scoreService.fetchScoresByLeague(id: storedLeagueId);
    }
    else {
      String leagueId = '${leagues[leagueName]['id']}';
      _leagueWiseScores = await _scoreService.fetchScoresByLeague(id: leagueId);
    }
    notifyListeners();
  }

  Future<void> loadFavouriteScores() async {
    String teamId = await LocalStorage.getString('teamId');
    _favouriteTeamScores = await _scoreService.fetchScoresByTeam(id: teamId);
    notifyListeners();
  }

  Future<void> loadLeagueTable({String leagueName}) async {
    if(leagueName == null) {
      String storedLeagueId = await LocalStorage.getString('leagueId');
      _leagueTableEntries = await _leagueTableService.fetchLeagueTable(id: storedLeagueId);
    }
    else {
      String leagueId = '${leagues[leagueName]['id']}';
      _leagueTableEntries = await _leagueTableService.fetchLeagueTable(id: leagueId);
    }
    notifyListeners();
  }

  Future<void> loadTopScorers({String leagueName}) async {
    if(leagueName == null) {
      String storedLeagueId = await LocalStorage.getString('leagueId');
      _topScorers = await _topScorerService.fetchTopScorer(leagueId: storedLeagueId);
    }
    else {
      String leagueId = '${leagues[leagueName]['id']}';
      _topScorers = await _topScorerService.fetchTopScorer(leagueId: leagueId);
    }
    notifyListeners();
  }


}