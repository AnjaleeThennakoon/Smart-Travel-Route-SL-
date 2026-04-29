// lib/main.dart
import 'package:flutter/material.dart';
import 'routers/app_router.dart';
import 'screens/onboarding_screen.dart';
import 'services/image_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Test API connection
  final isApiWorking = await ImageApiService.testApiConnection();
  print('🔧 API Status: ${isApiWorking ? "WORKING ✅" : "NOT WORKING ❌"}');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ayubo Travel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2C3E50),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C3E50),
          primary: const Color(0xFF2C3E50),
          secondary: const Color(0xFF3498DB),
        ),
        fontFamily: 'Poppins',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/onboarding',
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
