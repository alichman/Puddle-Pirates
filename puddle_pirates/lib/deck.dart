import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:puddle_pirates/battleship.dart';
import 'package:puddle_pirates/card.dart';
import 'package:puddle_pirates/states.dart';

class Deck {
  final List<GameCard> deck = [];
  final Random random = Random();

  /// Loads deck from JSON file
  Future<void> initialize() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/cards.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> deckJson = jsonData['deck'];

      deck.clear();
      deck.addAll(deckJson.map((cardJson) => GameCard.fromJson(cardJson)));
      // Store card effects inside cards on creation
      for (GameCard c in deck) {
        c.effect = _getCardEffect(c);
      }
    } catch (e) {
      throw Exception('Error initializing deck: $e');
    }
  }

  /// Draws a card based on its probability.
  GameCard draw() {
    if (deck.isEmpty) throw Exception('No cards available in deck.');

    double totalProbability =
        deck.fold(0, (sum, card) => sum + card.probability);
    double drawPoint = random.nextDouble() * totalProbability;
    double cumulative = 0;

    for (var card in deck) {
      cumulative += card.probability;
      if (drawPoint <= cumulative) {
        return card;
      }
    }
    throw Exception('Unexpected draw error.');
  }

  // TODO: String param here isn't great.
  // We should probably have an enum with all card names.
  /// Gives a specific card to the player.
  GameCard give(String cardName) {
    for (var card in deck) {
      if (card.name == cardName) {
        return card;
      }
    }
    throw Exception('Specified card not found.');
  }

  /// Maps a GameCard callback string to an existing function
  static void Function(BuildContext) _getCardEffect(GameCard card) {
    final Map<String, void Function(BuildContext)> callbackMap = {
      "tacticalRepositioning": tacticalRepositioning,
      "volleyFire": volleyFire,
      "repairCrew": repairCrew,
      "intelligence": intelligence,
    };

    return callbackMap[card.callbackString] ??
        (BuildContext context) {
          print("Unknown card effect: ${card.callbackString}");
        };
  }
  
  /// Card callbacks

  static void tacticalRepositioning(BuildContext context) {

    final gameState = Provider.of<GameState>(context, listen:false);

    gameState.setQuickEffect(() {
      final grid = gameState.currentPlayer.grid;
      gameState.requestTarget('Tactical Repositioning: Select Ship',
      // Check that selected square has a ship
      (Coord square) => grid.getShipFromSquare(square) != null,
      () {
        final oldShip = grid.getShipFromSquare(
          gameState.targetList[0]
        )!;
        gameState.requestTarget('Tactical Repositioning: Select empty spot',
          // Check for space for the ship at selected spot
          (Coord square) {
            final newSquares = rebaseCoords(oldShip.getOccupiedSquares(), square);
            if (newSquares == null) return false;
            return grid.areSquaresEmpty(newSquares, checkHits: true);
          },
          () {
            // Add new ship and transfer damage
            final newShip = grid.addShip(oldShip.type, gameState.targetList[1], oldShip.vert);
            grid.setHits(rebaseCoords(
                oldShip.getOccupiedSquares().where((s) => grid.getShotFromSquare(s) == Shot.hit).toList(),
                newShip.base,
                forcedBase: oldShip.base
              )!,
              Shot.hit
            );
            // Clear old ship and hits
            grid.removeShip(oldShip);
            grid.setHits(oldShip.getOccupiedSquares()
              .where((s) => grid.getShotFromSquare(s) != Shot.threat).toList(), null);
          });
      });
    });
  }

  static void volleyFire(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen:false);

    gameState.setAttackModifier((Coord target) {
      // Select a diamond region around target
      final List<Coord> squares = [
                    target.shift(0,-1),
        target.shift(1, 0), target, target.shift (-1, 0),
                    target.shift(0,1)
      ];
      gameState.opponent.grid.setAttack(squares);
    });
  }

  static void repairCrew(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen:false);
    final grid = gameState.currentPlayer.grid;

    gameState.requestTarget('Select ship',
    (Coord square) {
      // Must have a damaged, unsunk ship.
      final ship = grid.getShipFromSquare(square);
      if (ship == null || ship.isSunk) return false;
      return !grid.areSquaresEmpty(ship.getOccupiedSquares(), checkShips: false, checkHits: true);
    },
    () {
      final ship = grid.getShipFromSquare(gameState.targetList.last)!;
      grid.setHits(ship.getOccupiedSquares(), null);
    });
  }

  static void intelligence(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen:false);
    
    final randomCard = gameState.opponent.hand.getRandomCard();
    gameState.setOverlay(
      // TODO: Improve UI when UI MRs are merged
      randomCard == null ? Text('No cards') :
        CardWidget(card: randomCard, callback: () => gameState.setOverlay(null)));
  }
}


// Glorified list with notifier.
class Hand extends ChangeNotifier{
  final List<GameCard> cards = [];
  final Deck sourceDeck;

  Hand({required this.sourceDeck});

  GameCard? lastRemovedCard;
  final rand = Random();

  // Optional cardName: draw specific card
  void draw({String? cardName, bool refresh=true}) {
    if (cardName != null) {
      cards.add(sourceDeck.give(cardName));
    } else {
      cards.add(sourceDeck.draw());
    }
    if (refresh) notifyListeners();
  }

  void removeCard(GameCard card) {
    cards.remove(card);
    lastRemovedCard = card;
    notifyListeners();
  }

  // Adds the last-played card to hand.
  // Returns cost of card
  int returnLastCard() {
    if (lastRemovedCard == null) return 0;
    cards.add(lastRemovedCard!);
    lastRemovedCard = null;
    notifyListeners();
    return cards.last.price;
  }

  GameCard? getRandomCard() {
    if (cards.isEmpty) return null;
    return cards[rand.nextInt(cards.length)];
  }

  bool hasPlayableIntercepts(int money) {
    for (GameCard card in cards){
      if (card.type == CardType.intercept && card.price <= money) return true;
    }
    return false;
  }
}