import 'package:flutter/material.dart';
import '../features/auth/home_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/auth/profile_page.dart';
import '../features/auth/explore_screen.dart';
import '../features/auth/saved_page.dart';
import '../features/auth/bucket_page.dart';

class AppRouter {
  // Route names
  static const String login = '/';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String explore = '/explore';
  static const String saved = '/saved';
  static const String bucket = '/bucket';

  // Route generator
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );

      case explore:
        return MaterialPageRoute(
          builder: (_) => const ExploreScreen(),
          settings: settings,
        );

      case saved:
        return MaterialPageRoute(
          builder: (_) => const SavedPage(),
          settings: settings,
        );

      case bucket:
        return MaterialPageRoute(
          builder: (_) => const BucketPage(),
          settings: settings,
        );

      default:
        // If route not found, go to login page
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
    }
  }

  // Helper method to navigate (optional)
  static void pushNamed(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  // Helper method to push replacement (optional)
  static void pushReplacementNamed(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  // Helper method to pop (go back)
  static void pop(BuildContext context) {
    Navigator.pop(context);
  }
}
