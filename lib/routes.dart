import 'package:flutter/material.dart';
import 'package:gerador_de_senhas/screens/home_screen.dart';
import 'package:gerador_de_senhas/screens/intro_screen.dart';
import 'package:gerador_de_senhas/screens/login_screen.dart';
import 'package:gerador_de_senhas/screens/new_password_screen.dart';
import 'package:gerador_de_senhas/screens/splash_screen.dart';

class Routes {
  static const String splash = '/';
  static const String intro = '/intro';
  static const String home = '/home';
  static const String login = '/login';
  static const String password = '/password';

  static Route<dynamic> generateRoute (RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case intro:
        return MaterialPageRoute(builder: (_) => IntroScreen());
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case password:
        return MaterialPageRoute(builder: (_) => PasswordScreen());

        default:
          return MaterialPageRoute(builder: (_) => Scaffold(body: Center(child: Text("Rota não encontrada!"),),));
    }
  }
}