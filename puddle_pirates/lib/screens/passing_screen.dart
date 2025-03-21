import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puddle_pirates/states.dart';

class PassingScreen extends StatelessWidget{
  PassingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Container(
      color: Colors.black, // black background
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pass the device to ${gameState.getCurrentPlayer().name}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (gameState.nextPath == null) {
                  throw Exception('Passing Screen Error - no next path');
                }
                Navigator.pushNamed(context, gameState.nextPath!);
                gameState.nextPath = null;
              },
              child: const Text(
                'To Next Turn',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}