/* Contains player and preference states, along with immediate helper methods.
Methods that involve logic outside of states should be done elsewhere. */

import 'package:flutter/material.dart';

class GameState extends ChangeNotifier {
  int round = 0;
}

// Will probably move this to a separate file once it grows.
class Player {
  String name = '';
  
}