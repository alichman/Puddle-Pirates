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
  // Ship types to still be created.
  // Placed ships will be stored in the grid.
  // Map notation to make a mutable copy.
  List<ShipType> ships = ShipType.values.map((t) => t).toList(); 
  int? selected;
  bool isVert = false;

  @override
  Widget build(BuildContext context) {
    const shipSize = 45;
    final gameState = context.watch<GameState>();
    final cPlayer = gameState.getCurrentPlayer();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Set up Board - ${cPlayer.name}"),
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Grid
          ChangeNotifierProvider.value(
            value: cPlayer.grid,
            child: Expanded(child: 
              Center(child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.95, // Take up 80% of the screen width.
                child: BattleshipGrid(callback: (square) {
                  if (selected == null) {
                    return;
                  }
                  // Try placing ship
                  try {
                    cPlayer.grid.addShip(ships[selected!], square, isVert);
                    setState(() {
                      callbackSuccess = true;
                      ships.removeAt(selected!);
                      selected = null;
                    });
                  } catch (e) {print(e);}
                },)
              )))
          ),
          // Ship selector
          Column(
            children: ships.map((s) => GestureDetector(
              onTap: () {
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
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => isVert = !isVert);
              },
              child: Text(
                "Rotation - ${isVert ? 'Vertical' : 'Horizontal'}",
                style: TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (ships.isNotEmpty) return;
                // uses index of cPlayer to check if other player is set up.
                if (gameState.cPlayer == 0) {
                  gameState.toNextPlayer();
                  ships = ShipType.values.map((t) => t).toList(); 
                  return;
                }
                Navigator.pushNamed(context, '/game_page');
              },
              child: const Text(
                "Continue",
                style: TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/game_creation');
              },
              child: const Text(
                "Back to Game Creation",
                style: TextStyle(fontSize: 16),
              ),
            ),
        ])
    );
  }
}
