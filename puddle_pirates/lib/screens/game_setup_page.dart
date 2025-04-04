import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puddle_pirates/battleship.dart';
import 'package:puddle_pirates/ship.dart';
import 'package:puddle_pirates/states.dart';
import 'package:puddle_pirates/widgets/pixel_button.dart';

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
    final deviceWidth = MediaQuery.of(context).size.width;

    // Ensure game state can navigate
    return PopScope(
      canPop: false,
      child: Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Set up - ${gameState.currentPlayer.name}",
        style: Theme.of(context).textTheme.bodyMedium,),
        /*
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
        */
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Grid
              ChangeNotifierProvider.value(
                value: gameState.currentPlayer.grid,
                child: Center(child: SizedBox(
                      width: deviceWidth * 0.95,
                      height: deviceWidth * 0.95,
                      child: BattleshipGrid(callback: (square) {
                        if (selected == null) {
                          return;
                        }
                        // Try placing ship
                        try {
                          gameState.currentPlayer.grid.addShip(ships[selected!], square, isVert);
                          setState(() {
                            callbackSuccess = true;
                            ships.removeAt(selected!);
                            selected = null;
                          });
                        } catch (e) {print(e);}
                      },)
                    ),
                )
              ),
              SizedBox(height: 20),
              
              // Ship selector
              PixelButton(
                onTap: () {
                  setState(() => isVert = !isVert);
                },
                text: "Rotation - ${isVert ? 'Vertical' : 'Horizontal'}",
                width: 300
              ),
              SizedBox(height: 20,),
              Column(
                children: ships.map((s) => GestureDetector(
                  onTap: () {
                    setState(() => selected = ships.indexOf(s));
                  },
                  child: SizedBox(
                    height: shipSize.toDouble(),
                    width: (shipSize * shipLengthMap[s]!).toDouble(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: ships.indexOf(s) == selected ? const Color.fromARGB(255, 0, 208, 7) : Colors.transparent,
                        border: Border.all(color: const Color.fromARGB(255, 0, 56, 2), width: 2),
                        borderRadius: BorderRadius.circular(5)
                      ),
                      
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(1),
                      child: Image.asset('assets/images/ships/${s.name}.png')
                    )
                  ),
                )).toList(),
              ),
              
          ]),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                PixelButton(
                  color: Colors.red.shade700,
                  text: "Back to Game Creation",
                  route: '/game_creation'
                ),
                PixelButton(
                  onTap: () {
                    if (ships.isNotEmpty) return;
                    // uses index of cPlayer to check if other player is set up.
                    if (gameState.cPlayerIndex == 0) {
                      ships = ShipType.values.map((t) => t).toList();
                      gameState.toNextPlayer(context, '/game_setup');
                      return;
                    }
                    gameState.toNextPlayer(context, '/game_page');
                  },
                  text: "Continue",
                ),
              ]),
              SizedBox(height: 50)
            ],
          ),
      ]),
    ));
  }
}
