import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puddle_pirates/battleship.dart';
import 'package:puddle_pirates/states.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  bool _showTurnConfirmation = false;

  void _showWinningPopup(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('${gameState.players[gameState.cPlayer].name} Wins!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showTurnConfirmationScreen() {
    setState(() {
      _showTurnConfirmation = true; // Show the full-screen confirmation screen
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    // Check if players list is empty
    if (gameState.players.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("No players set. Please go back and set players."),
        ),
      );
    }

    final cPlayer = gameState.getCurrentPlayer();

    return Scaffold(
      appBar: AppBar(
        title: Text("${cPlayer.name}'s Turn"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
      ),
      body: Stack(
        children: [
          // Main Game Content
          Column(
            children: [
              // Battleship Grid
              Expanded(
                child: ChangeNotifierProvider.value(
                  value: cPlayer.grid,
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: BattleshipGrid(
                        callback: (square) {
                          // Handle grid taps (logic will be added later)
                          print("Tapped on square: $square");
                        },
                      ),
                    ),
                  ),
                ),
              ),
              // Card Section (Horizontally Scrollable)
              Container(
                height: 120, // Fixed height for the card section
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: List.generate(4, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      width: 100, // Fixed width for each card
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[200],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          'Card $index',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // Click-to-Confirm Turn
              GestureDetector(
                onHorizontalDragEnd: (details) {
                  _showTurnConfirmationScreen(); // Show the full-screen confirmation screen
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue,
                  child: const Center(
                    child: Text(
                      'Click to Confirm Turn',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
              // Hidden Button for Testing Winning Screen
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () => _showWinningPopup(context),
                  child: const Text("Test Winning Screen"),
                ),
              ),
            ],
          ),
          // Turn Confirmation Screen
          if (_showTurnConfirmation)
            Container(
              color: Colors.black, // black background
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Pass the device to the next player',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        gameState.toNextPlayer(); // Switch the turn using GameState
                        setState(() {
                          _showTurnConfirmation = false; // Hide the confirmation screen
                        });
                      },
                      child: const Text(
                        'Confirm Turn Switch',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
