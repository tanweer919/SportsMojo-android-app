import 'package:get_it/get_it.dart';
import '../models/Score.dart';
import 'NewsService.dart';
import 'TeamService.dart';
import 'ScoreService.dart';
import 'StatService.dart';
import 'MatchEventService.dart';
import 'LeagueTableService.dart';
import 'TopScorerService.dart';
import '../Provider/HomeViewModel.dart';
import '../Provider/AppProvider.dart';
import '../Provider/FavouriteScoresViewModel.dart';
import '../Provider/MatchStatViewModel.dart';
import '../Provider/MatchEventViewModel.dart';
import '../models/User.dart';
import 'FirebaseService.dart';
import 'FirestoreService.dart';
import 'RemoteConfigService.dart';
import 'NetworkStatusService.dart';
import 'FirebaseMessagingService.dart';
import 'CustomRouter.dart';
import '../Provider/ThemeProvider.dart';
import 'AnalyticsService.dart';

GetIt locator = GetIt.instance;

Future setupLocator() async {
  DateTime now =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  RemoteConfigService remoteConfigService =
      await RemoteConfigService.getInstance();
  locator.registerLazySingleton<NewsService>(() => NewsService());
  locator.registerLazySingleton<TeamService>(() => TeamService());
  locator.registerLazySingleton<ScoreService>(() => ScoreService());
  locator.registerLazySingleton<StatService>(() => StatService());
  locator.registerLazySingleton<MatchEventService>(() => MatchEventService());
  locator.registerLazySingleton<LeagueTableService>(() => LeagueTableService());
  locator.registerLazySingleton<TopScorerService>(() => TopScorerService());
  locator.registerLazySingleton<FirebaseService>(() => FirebaseService());
  locator.registerLazySingleton<FirestoreService>(() => FirestoreService());
  locator.registerLazySingleton<AnalyticsService>(() => AnalyticsService());
  locator.registerLazySingleton<NetworkStatusService>(
      () => NetworkStatusService());
  locator.registerSingleton<RemoteConfigService>(remoteConfigService);
  locator.registerLazySingleton<FirebaseMessagingService>(
      () => FirebaseMessagingService());
  locator.registerLazySingleton<RouterService>(() => RouterService());
  locator.registerFactory<HomeViewModel>(() => HomeViewModel(0));
  locator.registerFactory<MatchStatViewModel>(() => MatchStatViewModel(null));
  locator.registerFactory<MatchEventViewModel>(() => MatchEventViewModel(null));
  locator.registerFactoryParam<FavouriteScoresViewModel, List<Score>, int>(
      (scores, index) => FavouriteScoresViewModel(scores, index));
  locator.registerFactoryParam<AppProvider, Map<String, dynamic>, User>(
      (map, currentUser) => AppProvider(
          0,
          map['leagueName'],
          map['notificationEnabled'],
          now.subtract(Duration(days: 90)),
          now.add(Duration(days: 7)),
          currentUser));
  locator.registerFactoryParam<ThemeProvider, AppTheme, void>(
      (theme, _) => ThemeProvider(theme));
}
