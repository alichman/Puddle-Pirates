/* Contains player and preference states, along with immediate helper methods.
Methods that involve logic outside of states should be done elsewhere. */

import 'package:flutter/material.dart';
import 'package:puddle_pirates/battleship.dart';
import 'package:puddle_pirates/card.dart';
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
    players = [Player(name: p1Name, hand: Hand(sourceDeck: gameDeck)), Player(name: p2Name, hand: Hand(sourceDeck: gameDeck))];
    gameDeck.initialize();
    cPlayerIndex = 0;
    round = 0;
    notifyListeners();
  }

  Player get currentPlayer => players[cPlayerIndex];
  Player get opponent => players[1-cPlayerIndex];

  // Hides previous screen, and navigates to screenPath
  // Switches players. 
  // Do not notify listeners in here. That will update the grids
  // before the passing screen is pushed. Listeners are notified in
  // the passing screen.
  void toNextPlayer(BuildContext context, String screenPath) {
    cPlayerIndex = 1 - cPlayerIndex;
    nextPath = screenPath;
    attackModifier = null;
    Navigator.pushNamed(context, '/passing_screen');
  }

  // Avoid using this if possible. This exists for when there's no other way
  // to ensure refresh timing is right and the game doesn't show players' info to opponents.
  void forceRefresh () => notifyListeners();

  // Booster effects need to be moveable. They are only cleared
  // after end of turn, when attack is finalized (see toNextPlayer).
  void Function(Coord)? attackModifier;
  void setAttackModifier (void Function(Coord) mod) {
    attackModifier = mod;
    notifyListeners();
  }

  // Unlike boosters, who always require a coord, quick effects take no coord.
  // To target things (Some effects may require that you select multiple targets)
  // use the target list.
  void Function()? quickEffect;
  List<Coord> targetList = [];
  String? targetPrompt;
  bool Function(Coord)? validator;

  // The call made by a card's effect function
  void setQuickEffect(VoidCallback func) {
    quickEffect = func;
    notifyListeners();
  }

  // Quick effects with targets are recursive with a trigger -
  // When you call requestTarget, the callback you provide
  // becomes the next quickEffect. This effect will go off once
  // addTarget is called by a responding widget.
  
  // Called by widget at appropriate time
  void doQuickEffect({baseCall=true}) {
    if (quickEffect == null) return;
    if(baseCall) targetList = [];
    quickEffect!();
    // If requestTarget gets called, this is not the last iteration.
    if(targetPrompt != null) return;
    quickEffect = null;
    notifyListeners();
  }

  // Prompt to widget
  void requestTarget(String prompt, bool Function(Coord)? responseValidator, VoidCallback nextEffect) {
    targetPrompt = prompt;
    quickEffect = nextEffect;
    validator = responseValidator;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Response from widget
  void addTarget(Coord square) {
    if (targetPrompt == null) return;
    if (validator != null && !validator!(square)) return; // Potential future refactor - return string error

    targetList.add(square);
    targetPrompt = null;
    notifyListeners();
    doQuickEffect(baseCall: false);
  }

  // To be used for error handling by card logic
  void removeLastTarget() {
    targetList.removeLast();
  }

  // Clear all values, return played card.
  void cancelQuickEffect() {
    quickEffect = null;
    targetList = [];
    targetPrompt = null;
    validator = null;

    currentPlayer.returnLastCardToHand();
    notifyListeners();
  }

  // Overlays grid
  Widget? customOverlay;
  void setOverlay(Widget? widget) {
    customOverlay = widget;
    notifyListeners();
  }
}

class Player extends ChangeNotifier{
  String name;
  Hand hand;
  Player({required this.name, required this.hand});

  Grid grid = Grid();
  int money = 1000;
  List<GameCard> infras = [];

  bool spend(int amount) {
    if (amount > money) return false;
    money -= amount;
    notifyListeners();
    return true;
  }

  void addInfrastructure(GameCard card) {
    if (card.type != CardType.infrastructure) throw Exception('Card Error: $card is not an infrastructure');
    infras.add(card);
    notifyListeners();
  }

  void runAllInfras(BuildContext context) {
    for (GameCard c in infras) {
      c.effect!(context);
    }
  }

  void returnLastCardToHand() {
    spend(hand.returnLastCard() * -1);
  }
}
