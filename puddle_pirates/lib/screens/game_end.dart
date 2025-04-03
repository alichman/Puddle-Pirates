import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puddle_pirates/battleship.dart';
import 'package:puddle_pirates/states.dart';
import 'package:puddle_pirates/widgets/exit_button.dart';
import 'package:puddle_pirates/widgets/pixel_button.dart';

class EndScreen extends StatelessWidget {
  const EndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final gridSize = min(MediaQuery.of(context).size.width * 0.95, MediaQuery.of(context).size.height * 0.3);

    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        // Losing player grid
        Column(children: [
          Text(
            '${gameState.currentPlayer.name} - \$${gameState.currentPlayer.money}',
            style: const TextStyle(
              fontSize: 20,
              fontFamily: "PixelFont",
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),  
          ChangeNotifierProvider.value(
            value: gameState.currentPlayer.grid,
            child: Center(
              child: SizedBox(
                width: gridSize,
                height:gridSize,
                child: BattleshipGrid(),
              ),
            ),
          ),
        ]),
        SizedBox(height: 40),
        // Main text
        Text(
          '${gameState.opponent.name} WINS',
          style: const TextStyle(
            fontSize: 20,
            fontFamily: "PixelFont",
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 40),
        // Winning player grid
        Column(children: [
          ChangeNotifierProvider.value(
            value: gameState.opponent.grid,
            child: Center(
              child: SizedBox(
                width: gridSize,
                height:gridSize,
                child: BattleshipGrid(),
              ),
            ),
          ),
          Text(
            '${gameState.opponent.name} - \$${gameState.opponent.money}',
            style: const TextStyle(
              fontSize: 20,
              fontFamily: "PixelFont",
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]),
      ]),
      bottomNavigationBar: PixelButton(
        text: 'Home',
        route: '/',
        color: Colors.red.shade700,
        
      ),
    );
  }
}