import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puddle_pirates/states.dart';
import 'package:puddle_pirates/widgets/pixelated_wave.dart';
import 'package:puddle_pirates/widgets/pixel_button.dart';

class PassingScreen extends StatelessWidget {
  const PassingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final isPlayer1 = gameState.cPlayerIndex == 0;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isPlayer1
                  ? 'assets/images/player1Pass.png'
                  : 'assets/images/player2Pass.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              const PixelatedWave(height: 50),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pass the device to ${gameState.currentPlayer.name}',
                        style: const TextStyle(
                          fontFamily: "PixelFont",
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      PixelButton(
                        text: "To Next Turn",
                        onTap: () {
                          if (gameState.nextPath == null) {
                            throw Exception('Passing Screen Error - no next path');
                          }
                          gameState.forceRefresh();
                          Navigator.pushNamed(context, gameState.nextPath!);
                          gameState.nextPath = null;
                        },
                        color: Colors.blue,
                        width: 300,
                        height: 50,
                      ),
                    ],
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
