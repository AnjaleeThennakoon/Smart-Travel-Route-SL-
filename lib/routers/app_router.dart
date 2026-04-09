import 'package:flutter/material.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';

class AppRouter {
  static const String login = '/';
  static const String register = '/register';
  static const String home = '/home';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}
