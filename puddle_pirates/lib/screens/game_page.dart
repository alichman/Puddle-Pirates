import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:puddle_pirates/battleship.dart';
import 'package:puddle_pirates/card.dart';
import 'package:puddle_pirates/deck.dart';
import 'package:puddle_pirates/states.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  void _showWinningPopup(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('${gameState.currentPlayer.name} Wins!'),
          actions: <Widget>[
            TextButton(
              child: const Text('Back to home page'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/');
              },
            ),
          ],
        );
      },
    );
  }

  bool showAttackGrid = false;
  bool hasAttacked = false;
  bool isInterceptPhase = true;
  
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

    bool isCardPlayable(GameCard card) {
      if (card.price > gameState.currentPlayer.money) return false;
      if (isInterceptPhase) return card.type == CardType.intercept;
      if (showAttackGrid) return card.type == CardType.booster;

      return [CardType.deployment, CardType.infrastructure].contains(card.type);
    }

    // Something about this function creates conflicts between setState and notifyListeners.
    // refreshing calls here must not refresh, as they may case a crash.
    // Unfortunately I don't have the time to properly invetigate this.
    void endInterceptPhase() {
      if (!isInterceptPhase) return;

      gameState.currentPlayer.hand.draw(refresh: false);
      gameState.currentPlayer.grid.executeAttack(refresh: false);
      setState(() => isInterceptPhase = false);

      if (gameState.opponent.grid.checkLoss()) {
        _showWinningPopup(context);
        return;
      }
    }  

    // Intercept phase auto-skip
    if (isInterceptPhase &&
      !gameState.currentPlayer.hand.hasPlayableIntercepts(
        gameState.currentPlayer.money
    )){
      endInterceptPhase();
    }    

    return Scaffold(
      appBar: AppBar(
        title: Text("${gameState.currentPlayer.name}'s Turn"),
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
              // Battleship Grids
              [Expanded(child: ChangeNotifierProvider.value(
                value: gameState.currentPlayer.grid,
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: BattleshipGrid(
                      callback: (square) {
                        print("Tapped on square: $square");
                        // TODO: insert targeted card effect logic
                      },
                    ),
                  ),
                ),
              )),
              Expanded(child: ChangeNotifierProvider.value(
                value: gameState.opponent.grid,
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: BattleshipGrid(
                      attackMode: true,
                      callback: (square) {
                        if (gameState.attackModifier != null) {
                          gameState.attackModifier!(square);
                        } else {
                          gameState.opponent.grid.setAttack([square], clearCurrentAttacks: true);
                        }
                        setState(() => hasAttacked = true);
                      },
                    ),
                  ),
                ),
              ))][showAttackGrid ? 1:0],

              isInterceptPhase ? FloatingActionButton(
                onPressed: endInterceptPhase,
                child: Text('Done intercept')
              ): FloatingActionButton(
                onPressed: () => setState(() => showAttackGrid = !showAttackGrid),
                child: Text(showAttackGrid ? 'Your grid' : 'Attack grid')
              ),

              Selector<GameState, int>(
                selector: (_, g) => g.currentPlayer.money,
                builder: (context, money, child) => Text('Money: \$$money'), // Would be nice to replace with a horizontal bar
              ),
              // Card Section (Horizontally Scrollable)
              ChangeNotifierProvider.value(value: gameState.currentPlayer.hand, child:
                Container(
                  height: 120, // Fixed height for the card section
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Consumer<Hand>(
                    builder:(context, hand, child) => ListView(
                    scrollDirection: Axis.horizontal,
                    children: hand.cards.map((card) => CardWidget(
                        card: card,
                        callback: (){
                          hand.removeCard(card);
                          gameState.currentPlayer.spend(card.price);
                          gameState.forceRefresh();
                        },
                        playable: isCardPlayable(card)
                    )).toList()
                  ),
              ))),
              // Click-to-Confirm Turn
              GestureDetector(
                onHorizontalDragEnd: (details) {
                  if(!hasAttacked) return;
                  gameState.toNextPlayer(context, '/game_page');
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: hasAttacked ? Colors.blue : Colors.grey,
                  child: Center(
                    child: Text(
                      hasAttacked ? 'Click to Confirm Turn':'You have not attacked',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
              // Hidden Button for Testing Winning Screen
              // TODO: remove when not needed (real win is now achievable)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () => _showWinningPopup(context),
                  child: const Text("Test Winning Screen"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
