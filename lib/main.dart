import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routers/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zwcawavkavpcnfhcjjbq.supabase.co',
    anonKey: 'sb_publishable_-P1NGNIkGT6UtxcdEj93Ug_wC5qmBdG',
  );

  checkSupabaseInit();

  runApp(const MyApp());
}

void checkSupabaseInit() {
  final client = Supabase.instance.client;
  print('✅ Supabase client initialized successfully');
  print('Auth: ${client.auth}');
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
