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

  /// Placeholder Callback Functions
  /// TODO: move to separate file after implementation
  static void tacticalRepositioning(BuildContext context) {
    print("Tactical Repositioning");
  }

  static void volleyFire(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen:false);

    gameState.setAttackModifier((Coord target) {
      // Select a diamond region around target
      final List<Coord> squares = [
        target.shift(0,-1),
        target, target.shift(1, 0), target.shift (-1, 0),
        target.shift(0,1)
      ];
      gameState.opponent.grid.setAttack(squares);
    });
  }

  static void repairCrew(BuildContext context) {
    print("Repair Crew");
  }

  static void intelligence(BuildContext context) {
    print("Intelligence");
  }
}


// Glorified list with notifier.
class Hand extends ChangeNotifier{
  final List<GameCard> cards = [];
  final Deck sourceDeck;

  Hand({required this.sourceDeck});

  // Optional cardName: draw specific card
  void draw({String? cardName}) {
    if (cardName != null) {
      cards.add(sourceDeck.give(cardName));
    } else {
      cards.add(sourceDeck.draw());
    }
    notifyListeners();
  }

  void removeCard(GameCard card) {
    cards.remove(card);
    notifyListeners();
  }

  // TODO: we need to determine the right word to use everywhere.
  // 'money' isn't great.
  bool hasPlayableIntercepts(int money) {
    for (GameCard card in cards){
      if (card.type == CardType.intercept && card.price < money) return true;
    }
    return false;
  }
}