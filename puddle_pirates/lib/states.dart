/* Contains player and preference states, along with immediate helper methods.
Methods that involve logic outside of states should be done elsewhere. */

import 'package:flutter/material.dart';
import 'package:puddle_pirates/battleship.dart';
import 'package:puddle_pirates/deck.dart';

class GameState extends ChangeNotifier {
  int round = 0;
  int cPlayerIndex = 0;
  List<Player> players = [];

  final gameDeck = Deck();

  String? nextPath;

  // No AI Support yet.
  // Also resets game values.
  void setNewPlayers(String p1Name, String p2Name) {
    players = [
      Player(name: p1Name, hand: Hand(sourceDeck: gameDeck)),
      Player(name: p2Name, hand: Hand(sourceDeck: gameDeck))
    ];
    gameDeck.initialize();
    cPlayerIndex = 0;
    round = 0;
    notifyListeners();
  }

  Player get currentPlayer => players[cPlayerIndex];
  Player get opponent => players[1 - cPlayerIndex];

  // Avoid using this if possible. This exists for when there's no other way
  // to ensure refresh timing is right and the game doesn't show players' info to opponents.
  void forceRefresh() => notifyListeners();

  // Hides previous screen, and navigates to screenPath
  // Switches players.
  // Do not notify listeners in here. That will update the grids
  // before the passing screen is pushed. Listeners are notified in
  // the passing screen.
  void toNextPlayer(BuildContext context, String screenPath) {
    cPlayerIndex = 1 - cPlayerIndex;
    nextPath = screenPath;
    Navigator.pushNamed(context, '/passing_screen');
  }
}

class Player extends ChangeNotifier {
  String name;
  Hand hand;
  Player({required this.name, required this.hand});

  Grid grid = Grid();
  int money = 1000; //TODO: find a more appropriate word

  bool spend(int amount) {
    if (amount > money) return false;
    money -= amount;
    notifyListeners();
    return true;
  }
}
