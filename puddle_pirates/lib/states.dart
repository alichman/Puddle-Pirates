/* Contains player and preference states, along with immediate helper methods.
Methods that involve logic outside of states should be done elsewhere. */

import 'package:flutter/material.dart';
import 'package:puddle_pirates/battleship.dart';

class GameState extends ChangeNotifier {
  int round = 0;
  List<Player> players = [Player('p1'), Player('p2')];  
}

// Will probably move this to a separate file once it grows.
class Player {
  String name;

  Player(this.name);
  Grid grid = Grid();
}
