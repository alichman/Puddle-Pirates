import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puddle_pirates/screens/game_setup_page.dart';
import 'package:puddle_pirates/screens/main_menu.dart';
import 'package:puddle_pirates/screens/game_creation.dart';
import 'package:puddle_pirates/screens/saved_games.dart';
import 'package:puddle_pirates/screens/card_library.dart';
import 'package:puddle_pirates/screens/settings.dart';
import 'package:puddle_pirates/screens/game_page.dart';
import 'package:provider/provider.dart';
import 'package:puddle_pirates/states.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (context) => GameState(),
    child: const PuddlePiratesApp())
  );
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
        '/game_setup_page': (context) => const GameSetupPage(),
        '/saved_games': (context) => const SavedGamesScreen(),
        '/card_library': (context) => const CardLibraryScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/game_page': (context) => const GamePage(),
      },
    );
  }
}
