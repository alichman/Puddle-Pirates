import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puddle_pirates/states.dart';

enum GameMode { twoPlayer, ai }

class GameCreationScreen extends StatefulWidget {
  const GameCreationScreen({super.key});

  @override
  GameCreationScreenState createState() => GameCreationScreenState();
}

class GameCreationScreenState extends State<GameCreationScreen> {
  GameMode _selectedMode = GameMode.twoPlayer;
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();
  final TextEditingController _playerNameController = TextEditingController();

  @override
  void dispose() {
    _player1Controller.dispose();
    _player2Controller.dispose();
    _playerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Create Game"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Game Mode',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                // Replace Row with Column for radio button options
                Column(
                  children: [
                    RadioListTile<GameMode>(
                      title: const Text('Two Player'),
                      value: GameMode.twoPlayer,
                      groupValue: _selectedMode,
                      onChanged: (GameMode? value) {
                        setState(() {
                          _selectedMode = value!;
                        });
                      },
                    ),
                    RadioListTile<GameMode>(
                      title: const Text('AI'),
                      value: GameMode.ai,
                      groupValue: _selectedMode,
                      onChanged: (GameMode? value) {
                        setState(() {
                          _selectedMode = value!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_selectedMode == GameMode.twoPlayer) ...[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _player1Controller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Player 1 Name",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _player2Controller,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Player 2 Name",
                      ),
                    ),
                  ),
                ] else if (_selectedMode == GameMode.ai) ...[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _playerNameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Your Name",
                      ),
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    onPressed: () {
                      final gameState = Provider.of<GameState>(context, listen: false);
                        String formatPlayerName(String text, int pNum) {
                          if (text.isEmpty) return 'Player #$pNum';
                          return text;
                        }
                        if (_selectedMode == GameMode.twoPlayer) {
                          gameState.setNewPlayers(
                            formatPlayerName(_player1Controller.text, 1),
                            formatPlayerName(_player2Controller.text, 2),
                          );
                        } else if (_selectedMode == GameMode.ai) {
                          gameState.setNewPlayers(
                            formatPlayerName(_playerNameController.text, 1),
                            "AI", // Default AI name
                          );
                        }
                        Navigator.pushNamed(context, '/game_setup');
                    },
                    child: const Text(
                      "Start Game",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}