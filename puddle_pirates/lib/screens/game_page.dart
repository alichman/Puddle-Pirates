import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puddle_pirates/battleship.dart';
import 'package:puddle_pirates/states.dart';


class GameSetupPage extends StatefulWidget {
  @override
  _GameSetupState createState() => _GameSetupState();  
}

class _GameSetupState extends State<GameSetupPage> {
  @override
  Widget build(BuildContext context) {
    final cPlayer = globalGameState.getCurrentPlayer();

    return Column(
      children: [
        // Grid
        ChangeNotifierProvider.value(
          value: cPlayer.grid,
          child: BattleshipGrid()
        ),
      ]
    );
  }
}

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Game Page"),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Back to Main Menu"),
        ),
      ),
    );
  }
}
