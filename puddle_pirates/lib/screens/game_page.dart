import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puddle_pirates/battleship.dart';
import 'package:puddle_pirates/states.dart';


class GameSetupPage extends StatefulWidget {
  const GameSetupPage({super.key});

  @override
  State<GameSetupPage> createState() => _GameSetupState();  
}

class _GameSetupState extends State<GameSetupPage> {
  bool callbackSuccess = false;
  final cPlayer = globalGameState.getCurrentPlayer();

  @override
  Widget build(BuildContext context) {
    // Placed ships will be stored in the grid.
    final ships = ShipType.values; // Ship types to still be created.
    int? selected = null;
    bool vert = false;
    int shipSize = 20;

    return Column(
      children: [
        // Grid
        ChangeNotifierProvider.value(
          value: cPlayer.grid,
          child: Expanded(child: 
            Center(child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95, // Take up 80% of the screen width.
              child: BattleshipGrid(callback: (square) {
                if (selected == null) {
                  print('none selected');
                  return;
                }
                // Try placing ship
                try {
                  cPlayer.grid.addShip(ships[selected], square, vert);
                } catch (e) {
                  print('haha shidiot fuck you');
                }

                setState(() => callbackSuccess = true); 
                print('callbackSuccess set $callbackSuccess');
              },)
            )))
        ),
        // Ship selector
        Expanded(child: Column(
          children: ships.map((s) => SizedBox(
            height: shipSize.toDouble(),
            width: (shipSize * shipLengthMap[s]!).toDouble(),
            child: Container(
              color: Colors.green,
              alignment: Alignment.center,
              margin: EdgeInsets.all(1),
            ))
          ).toList())),
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
