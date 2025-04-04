import 'package:flutter/material.dart';
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
      if (gameState.quickEffect != null) return false;
      if (card.price > gameState.currentPlayer.money) return false;
      if (isInterceptPhase) return card.type == CardType.intercept;
      if (showAttackGrid) return card.type == CardType.booster;

      return [CardType.deployment, CardType.infrastructure].contains(card.type);
    }

    // Something about this function creates conflicts between setState and notifyListeners.
    // Refreshing calls here must not refresh, as they may cause a crash.
    // Unfortunately I don't have the time to properly invetigate this.
    void endInterceptPhase() {
      if (!isInterceptPhase || gameState.quickEffect != null) return;

      gameState.currentPlayer.hand.draw(refresh: false);
      gameState.currentPlayer.grid.executeAttack(refresh: false);
      setState(() => isInterceptPhase = false);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (gameState.currentPlayer.grid.checkLoss()) {
          Navigator.pushNamed(context, '/game_end_screen');
        }
        gameState.currentPlayer.runAllInfras(context);
      });
    }

    // Check for quick effects
    if (gameState.quickEffect != null && gameState.targetPrompt == null) gameState.doQuickEffect();
    
    // Intercept phase auto-skip
    if (isInterceptPhase &&
      !gameState.currentPlayer.hand.hasPlayableIntercepts(
        gameState.currentPlayer.money
    )){
      endInterceptPhase();
    }

    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("${gameState.currentPlayer.name}'s Turn",
        style: Theme.of(context).textTheme.bodyMedium),
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
              /// Battleship Grids
              // own grid
              [SizedBox(
                height: deviceWidth,
                width: deviceWidth,
                child: ChangeNotifierProvider.value(
                  value: gameState.currentPlayer.grid,
                  child: Center(
                    child: BattleshipGrid(
                      overlay: gameState.customOverlay,
                      callback: (square) {
                        if (gameState.customOverlay != null){
                          gameState.setOverlay(null);
                        }
                        gameState.addTarget(square);
                      },
                      onSwipe: (isRight) {
                        setState(() => showAttackGrid = true);
                      }
                    ),
                  ),
                )
              ),
              // opponent grid
              SizedBox(
                height: deviceWidth,
                width: deviceWidth,
                child: ChangeNotifierProvider.value(
                value: gameState.opponent.grid,
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
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
                      onSwipe: (isRight) {
                        setState(() => showAttackGrid = false);
                      }
                    ),
                  ),
                ),
              ))][showAttackGrid ? 1:0],
              Text('Swipe to see ${showAttackGrid ? 'your board' : 'attack board'}',
                style: Theme.of(context).textTheme.bodySmall,
               ),

              SizedBox(height: 20),
              // Click-to-Confirm Turn
              GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (gameState.quickEffect != null) {
                    gameState.cancelQuickEffect();
                  } else if(hasAttacked) {
                    gameState.toNextPlayer(context, '/game_page');
                  } else if (isInterceptPhase) {
                    endInterceptPhase();
                  } 
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: hasAttacked || gameState.quickEffect != null ? const Color.fromARGB(255, 0, 73, 134) : const Color.fromARGB(255, 68, 100, 127),
                  child: Center(
                    child: Text(
                      gameState.targetPrompt ??
                        (hasAttacked ? 'Click to Confirm Turn':
                        isInterceptPhase ? 'Skip Intercept' :
                         'You have not attacked'),
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),

              // Send everything to bottom
              Expanded(child: SizedBox.shrink()),
              // Money bar
              Selector<GameState, int>(
                selector: (_, g) => g.currentPlayer.money,
                builder: (context, money, child) => Stack(
                  children: [
                    SizedBox(
                      height: 30,
                      width: deviceWidth * 0.8,
                      child: LinearProgressIndicator(
                        value: money / 1000,
                        backgroundColor: const Color.fromARGB(255, 0, 73, 134),
                        color: const Color.fromARGB(255, 8, 180, 45),
                        borderRadius: BorderRadius.circular(15),
                      )
                    ),
                    Positioned(
                      right: deviceWidth*0.8 * (1- money/1000) + 10, 
                      top: 5,
                      child: Text('\$$money')
                    )
                  ],
                ), // Would be nice to replace with a horizontal bar
              ),
              // Card Section (Horizontally Scrollable)
              ChangeNotifierProvider.value(value: gameState.currentPlayer.hand, child:
                Container(
                  height: detailLevelHeightMap[gameState.targetPrompt == null ? 2: 1]!,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Consumer<Hand>(
                    builder:(context, hand, child) => ListView(
                    scrollDirection: Axis.horizontal,
                    children: hand.cards.map((card) => CardWidget(
                        card: card,
                        callback: (){
                          if (card.type == CardType.infrastructure) {
                            gameState.currentPlayer.addInfrastructure(card);
                          }

                          hand.removeCard(card);
                          gameState.currentPlayer.spend(card.price);
                          gameState.forceRefresh();
                        },
                        playable: isCardPlayable(card),
                        skipEffect: card.type == CardType.infrastructure,
                        detailLevel: gameState.targetPrompt == null ? 2: 1,
                    )).toList()
                  ),
              ))),
            ],
          ),
        ],
      ),
    );
  }
}
