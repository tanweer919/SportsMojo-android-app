import 'package:flutter/cupertino.dart';
import '../screens/HomeScreen.dart';
import '../screens/Score.dart';
import '../screens/News.dart';
class Router {
  Route<dynamic> generateRoutes(RouteSettings settings) {
    final List<String> validRoutes = [
      '/home',
      '/score',
      '/news'
    ];
    if(validRoutes.contains(settings.name)) {
      return customRoutes(settings.name);
    }
  }

  PageRouteBuilder<dynamic> customRoutes(String route) {
    Map<String, Widget> screens = {
      '/home': HomeScreen(),
      '/score': ScoreScreen(),
      '/news': NewsScreen()
    };

    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => screens[route],
      transitionsBuilder: (_, anim, __, child) {
        return FadeTransition(opacity: anim, child: child);
      }
    );
  }
}