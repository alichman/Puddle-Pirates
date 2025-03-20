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
  // Ship types to still be created.
  // Placed ships will be stored in the grid.
  // Map notation to make a mutable copy.
  final ships = ShipType.values.map((t) => t).toList(); 
  int? selected;
  bool vert = false;

  @override
  Widget build(BuildContext context) {
    const shipSize = 50;

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
                  cPlayer.grid.addShip(ships[selected!], square, vert);
                  setState(() {
                    callbackSuccess = true;
                    ships.removeAt(selected!);
                    selected = null;
                  }); 
                  print('callbackSuccess set $callbackSuccess');
                } catch (e) {print(e);}
              },)
            )))
        ),
        // Ship selector
        Expanded(child: Column(
          children: ships.map((s) => GestureDetector(
            onTap: () { 
              print('in here - $selected');
              setState(() => selected = ships.indexOf(s));
            },
            child: SizedBox(
            height: shipSize.toDouble(),
            width: (shipSize * shipLengthMap[s]!).toDouble(),
            child: Container(
              color: ships.indexOf(s) == selected ? const Color.fromARGB(255, 43, 99, 45) : Colors.green,
              alignment: Alignment.center,
              margin: EdgeInsets.all(1),
            )))).toList(),
          )),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: () {
              if (ships.isNotEmpty) return;
              Navigator.pushNamed(context, '/game_page');
            },
            child: const Text(
              "Continue",
              style: TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/game_creation');
            },
            child: const Text(
              "Back to Game Creation",
              style: TextStyle(fontSize: 16),
            ),
          ),
      ]);
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
