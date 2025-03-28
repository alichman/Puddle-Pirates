/* Contains player and preference states, along with immediate helper methods.
Methods that involve logic outside of states should be done elsewhere. */

import 'package:flutter/material.dart';
import 'package:puddle_pirates/battleship.dart';
import 'package:puddle_pirates/deck.dart';

class GameState extends ChangeNotifier {
  int round = 0;
  int cPlayer = 0;
  List<Player> players = [];
  String? nextPath;
  BuildContext? _context;
  final gameDeck = Deck();

  // No AI Support yet.
  // Also resets game values.
  void setNewPlayers(String p1Name, String p2Name) {
    players = [Player(name: p1Name, hand: Hand(sourceDeck: gameDeck)), Player(name: p2Name, hand: Hand(sourceDeck: gameDeck))];
    gameDeck.initialize();
    cPlayer = 0;
    round = 0;
    notifyListeners();
  }

  void setContext(BuildContext newContext) {
    if (_context != null) return;
    _context = newContext;
  }

  Player getCurrentPlayer () => players[cPlayer];
  Player getOpponent () => players[1-cPlayer];

  // Avoid using this if possible. This exists for when there's no other way
  // to ensure refresh timing is right and the game doesn't show players' info to opponents.
  void forceRefresh () => notifyListeners();

  // Hides previous screen, and navigates to screenPath
  // Switches players. 
  // Do not notify listeners in here. That will update the grids
  // before the passing screen is pushed. Listeners are notified in
  // the passing screen.
  void toNextPlayer(String screenPath) {
    cPlayer = 1 - cPlayer;
    nextPath = screenPath;
    Navigator.pushNamed(_context!, '/passing_screen');
  }
}

class Player {
  String name;
  Hand hand;

  Player({required this.name, required this.hand});

  Grid grid = Grid();
}
