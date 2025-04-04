import 'package:flutter/material.dart';
import 'package:puddle_pirates/widgets/pixelated_wave.dart';
import 'package:puddle_pirates/widgets/pixel_button.dart';
import 'package:provider/provider.dart';
import 'package:puddle_pirates/states.dart';

class GameCreationScreen extends StatefulWidget {
  const GameCreationScreen({super.key});

  @override
  GameCreationScreenState createState() => GameCreationScreenState();
}

class GameCreationScreenState extends State<GameCreationScreen> {
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();

  @override
  void dispose() {
    _player1Controller.dispose();
    _player2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Create Game",
          style: TextStyle(
            fontFamily: "PixelFont",
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            color: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.home),
          color: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/oceanGameCreation.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              const PixelatedWave(height: 50),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 32.0),
                            child: Text(
                              'Enter Player Names',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: "PixelFont",
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _player1Controller,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Player 1 Name",
                                labelStyle: TextStyle(
                                  fontFamily: "PixelFont",
                                ),
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
                                labelStyle: TextStyle(
                                  fontFamily: "PixelFont",
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: PixelButton(
                              text: "Start Game",
                              // Don't provide a route, only onTap
                              onTap: () {
                                final gameState = Provider.of<GameState>(context, listen: false);

                                // Format player names if they are empty
                                String formatPlayerName(String text, int pNum) {
                                  if (text.isEmpty) return 'Player #$pNum';
                                  return text;
                                }

                                // Set the players in the game state
                                gameState.setNewPlayers(
                                  formatPlayerName(_player1Controller.text, 1),
                                  formatPlayerName(_player2Controller.text, 2),
                                );
                                Navigator.pushNamed(context, '/game_setup');
                              },
                              color: Colors.blue,
                              width: 220,
                              height: 60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const PixelatedWave(height: 50),
            ],
          ),
        ],
      ),
    );
  }
}
