/* Contains player and preference states, along with immediate helper methods.
Methods that involve logic outside of states should be done elsewhere. */

import 'package:flutter/material.dart';
import 'package:puddle_pirates/battleship.dart';

class GameState extends ChangeNotifier {
  int round = 0;
  int cPlayer = 0;
  List<Player> players = [];

  // No AI Support yet.
  // Also resets game values.
  void setNewPlayers(String p1Name, String p2Name) {
    players = [Player(p1Name), Player(p2Name)];
    cPlayer = 0;
    round = 0;
    notifyListeners();
  }

  Player getCurrentPlayer () => players[cPlayer];
  void toNextPlayer() {
    // 1 - 0 = 1, 1 - 1 = 0
    cPlayer = 1 - cPlayer;
    notifyListeners();
  }
}

// Will probably move this to a separate file once it grows.
class Player {
  String name;

  Player(this.name);
  Grid grid = Grid();
}
