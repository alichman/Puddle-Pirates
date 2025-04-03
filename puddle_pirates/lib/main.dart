import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puddle_pirates/screens/game_end.dart';
import 'package:puddle_pirates/screens/game_setup_page.dart';
import 'package:puddle_pirates/screens/main_menu.dart';
import 'package:puddle_pirates/screens/game_creation.dart';
import 'package:puddle_pirates/screens/passing_screen.dart';
import 'package:puddle_pirates/screens/saved_games.dart';
import 'package:puddle_pirates/screens/card_library.dart';
import 'package:puddle_pirates/screens/settings.dart';
import 'package:puddle_pirates/screens/game_page.dart';
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

        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 82,
            fontFamily: "PirateFont",
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 5,
                color: Colors.black.withAlpha(180),
              ),
            ],
          ),
          bodyMedium:  const TextStyle(
            fontFamily: "PixelFont",
            color: Colors.white,
            fontWeight: FontWeight.bold,
          )
        ),
        
        scaffoldBackgroundColor: const Color.fromARGB(255, 21, 108, 178),
        appBarTheme: AppBarTheme(
          color: const Color.fromARGB(255, 13, 68, 112),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      initialRoute: '/', // Starts at Main Menu
      routes: {
        '/': (context) => const MainMenu(),
        '/game_creation': (context) => const GameCreationScreen(),
        '/game_setup': (context) => const GameSetupPage(),
        '/saved_games': (context) => const SavedGamesScreen(),
        '/card_library': (context) => const CardLibraryScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/game_page': (context) => const GamePage(),
        '/passing_screen': (context) => PassingScreen(),
        '/game_end_screen': (context) => const EndScreen()
      },
    );
  }
}
