import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/gender_screen.dart';
import 'screens/age_screen.dart';
import 'screens/universities_screen.dart';
import 'screens/weather_screen.dart';
import 'screens/pokemon_screen.dart';
import 'screens/news_screen.dart';
import 'screens/about_screen.dart';

void main() => runApp(const ToolboxApp());

class ToolboxApp extends StatelessWidget {
  const ToolboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toolbox',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
      routes: {
        '/gender': (_) => const GenderScreen(),
        '/age': (_) => const AgeScreen(),
        '/universities': (_) => const UniversitiesScreen(),
        '/weather': (_) => const WeatherScreen(),
        '/pokemon': (_) => const PokemonScreen(),
        '/news': (_) => const NewsScreen(),
        '/about': (_) => const AboutScreen(),
      },
    );
  }
}
