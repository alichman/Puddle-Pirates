import 'package:flutter/material.dart';
import 'package:puddle_pirates/screens/main_menu.dart';
import 'package:puddle_pirates/screens/game_creation.dart';
import 'package:puddle_pirates/screens/saved_games.dart';
import 'package:puddle_pirates/screens/card_library.dart';
import 'package:puddle_pirates/screens/settings.dart';
import 'package:puddle_pirates/screens/game_page.dart';

void main() {
  runApp(const PuddlePiratesApp());
}

class PuddlePiratesApp extends StatelessWidget {
  const PuddlePiratesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puddle Pirates',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/', // Starts at Main Menu
      routes: {
        '/': (context) => const MainMenu(),
        '/game_creation': (context) => const GameCreationScreen(),
        '/saved_games': (context) => const SavedGamesScreen(),
        '/card_library': (context) => const CardLibraryScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/game_page': (context) => const GamePage(),
      },
    );
  }
}
