import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/water_tracking_screen.dart';
import 'screens/activity_screen.dart';
import 'screens/meals_screen.dart';
import 'screens/meal_detail_screen.dart';
import 'screens/ingredients_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/dashboard_screen.dart';

void main() => runApp(const ProviderScope(child: PHMApp()));

class PHMApp extends StatelessWidget {
  const PHMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case '/dashboard':
            return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
          case '/water':
            return MaterialPageRoute(builder: (_) => const WaterTrackingScreen());
          case '/activity':
          case '/log/activity':
            return MaterialPageRoute(builder: (_) => const ActivityScreen());
          case '/meals':
          case '/log/meal':
            return MaterialPageRoute(builder: (_) => const MealsScreen());
          case '/meal/detail':
            final meal = settings.arguments as MealModel?;
            return MaterialPageRoute(
              builder: (_) => MealDetailScreen(meal: meal),
            );
          case '/ingredients':
            return MaterialPageRoute(builder: (_) => const IngredientsScreen());
          case '/reminders':
            return MaterialPageRoute(builder: (_) => const RemindersScreen());
          case '/log/water':
            return MaterialPageRoute(builder: (_) => const WaterTrackingScreen());
          default:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
        }
      },
    );
  }
}