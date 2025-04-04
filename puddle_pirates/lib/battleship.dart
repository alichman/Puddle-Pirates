/*
  File for all logic related to battleship.
  Positions of ships, hits, and misses will be kept in the player's grid.

  Note: (0, 0) is in the top left
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puddle_pirates/ship.dart';


enum Shot {
  hit,
  miss,
  threat
}

// Defining our own Point class, since math Point uses num and we want to restrict to ints.
class Coord {
  int x;
  int y;
  Coord(this.x, this.y);

  @override
  String toString() {
    return '($x, $y)';
  }

  void validate () {
    if (x > 9 ||  x < 0) {
      throw Exception('Coordinate error: x $x is out of range');
    }
    if (y > 9 || y < 0) {
      throw Exception('Coordinate error: y $y is out of range');
    }
  }

  // Returns a new coordinate shifted by amount.
  // rshift+ -> right | dShift+ -> down
  Coord shift(int rShift, int dShift) => Coord(x+rShift, y+dShift);

  // Allow == comparison between coord objects
  @override
  bool operator == (Object other) =>
    identical(this, other) ||
    other is Coord && x == other.x && y == other.y;

  // Hashcode override: maps and such will place this based on the x and y components
  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

// returns new coords moved to new base, assuming first coord in list is the current base.
// returns null if new coords are invalid.
// forcedBase is an override for base for when your list doesn't have the transform origin.
List<Coord>? rebaseCoords(List<Coord> squares, Coord newBase, {Coord? forcedBase}) {
  if (squares.isEmpty) return [];
  final oldBase = forcedBase ?? squares[0];

  final xOffset = newBase.x - oldBase.x;
  final yOffset = newBase.y - oldBase.y;

  // Quickly check if coords are invalid by checking the last square.
  try {
    squares.last.shift(xOffset, yOffset).validate();
  } catch (e) {
    return null;
  }

  return squares.map<Coord>((s) => s.shift(xOffset, yOffset)).toList();
}

// Used for selectors based on all grid content.
class GridContent {
  final Ship? ship;
  final Shot? shot;

  GridContent(this.ship, this.shot);
}

class Grid extends ChangeNotifier{
  /* Grid containing all of the battleship info.
    Stores two 10x10 grids - one holding all ships,
    and one holding all attacks from the opponent.
    Additionally, ships will be stored in a list, and
    can be used to select their occupied area on the grid.
  */

  // 10x10 null grids
  final List<List<Ship?>> _shipGrid = List.generate(10, (_) => List.filled(10, null));
  final List<Ship> _ships = [];
  final List<List<Shot?>> _shotsGrid = List.generate(10, (_) => List.filled(10, null));
  List<Coord> threatened = []; // List of 'threat' shots to avoid iterating over entire grid with every attack

  // Abstracted table access
  Ship? getShipFromSquare (Coord square) {
    square.validate();
    return _shipGrid[square.x][square.y];
  }

  Shot? getShotFromSquare (Coord square) {
    square.validate();
    return _shotsGrid[square.x][square.y];
  }

  // Shortcut to checking multiple squares at once for any kind of content.
  bool areSquaresEmpty(List<Coord> squares, {bool checkShips=true, bool checkHits=false}) {
    for (Coord s in squares) {
      if (checkShips && getShipFromSquare(s) != null) return false;
      if (checkHits && getShotFromSquare(s) != null) return false;
    }
    return true;
  }

  Ship addShip (ShipType type, Coord base, bool vert) {
    // Add ship to grid and ships array
    final ship = Ship(type, base, vert);
    // Validate position
    if (!areSquaresEmpty(ship.getOccupiedSquares())) throw Exception('Grid Error: Line not empty');

    int x = base.x, y = base.y;
    for (int i=0; i < shipLengthMap[type]!; i++) {
      _shipGrid[x][y] = ship;
      if(vert) {y ++;} else {x++;}
    }
    _ships.add(ship);
    notifyListeners();
    return ship;
  }

  void removeShip (Ship? ship) {
    if (ship == null) {
      return;
    }
    for (Coord s in ship.getOccupiedSquares()){
      _shipGrid[s.x][ s.y] = null;
    }
    _ships.remove(ship);
    notifyListeners();
  }

  // Checks if a ship is sunk and sets Ship.isSunk.
  // Returns result for local logic.
  bool checkShipSink (Ship ship) {
    final squares = ship.getOccupiedSquares();
    for (Coord s in squares) {
      if (getShotFromSquare(s) == null) return false;
    }

    ship.isSunk = true;
    return true;
  }

  bool checkLoss () {
    for (Ship s in _ships){
      if (!s.isSunk) return false;
    }
    return true;
  }

  void attack (List<Coord> squares, {bool refresh=true}) {
    for (Coord s in squares){
      s.validate();
      // Don't allow attacks on previous attacked squares.
      if ([Shot.hit, Shot.miss].contains(getShotFromSquare(s))) throw Exception("Grid Error: Can't attack non-empty square");

      final hitShip = getShipFromSquare(s);
      if (hitShip == null) {
        _shotsGrid[s.x][s.y] = Shot.miss;
      } else {
        _shotsGrid[s.x][s.y] = Shot.hit;
        checkShipSink(hitShip);
      }
    }
    if (refresh) notifyListeners();
  }

  // Sets hit values without additional logic. Not to be used for attacking.
  void setHits (List<Coord> squares, Shot? value) {
    for (Coord s in squares) {
      s.validate();
      _shotsGrid[s.x][s.y] = value;
    }
    notifyListeners();
  }

  // Validates each square, and removes invalid ones.
  // Attack executed by executeAttack() on the current player at that time.
  void setAttack (List<Coord> squares, {bool clearCurrentAttacks=true}){
    if (clearCurrentAttacks) {
      for (Coord t in threatened) {
        _shotsGrid[t.x][t.y] = null;
      }
      threatened = [];
    }

    for (Coord s in squares) {
      try {
        s.validate();
        if (getShotFromSquare(s) == null) {
          threatened.add(s);
          _shotsGrid[s.x][s.y] = Shot.threat;
        }
      } catch (e) {print(e);} // Expected error if part of an attack is out of range.
    }
    notifyListeners();
  }

  void executeAttack({bool refresh=true}) {
    attack(threatened, refresh: refresh);
    // Attack notifies listeners. No need to do it again.
    threatened = [];
  }
}

// Overlays a 1-gridsquare image at desired position.
class PositionedMarker extends StatelessWidget{
  final Coord base;
  final Shot mark;
  final double squareSize;
  final bool ownGrid;

  const PositionedMarker(this.base, this.squareSize, this.mark, this.ownGrid, {super.key});

  static const Map<Shot, String> markPathMapOwn = {
    Shot.hit: 'assets/images/markers/fireball.png',
    Shot.miss: 'assets/images/markers/blueo.png',
    Shot.threat: 'assets/images/markers/target.png'
  };
  static const Map<Shot, String> markPathMapOpp = {
    Shot.hit: 'assets/images/markers/redx.png',
    Shot.miss: 'assets/images/markers/blueo.png',
    Shot.threat: 'assets/images/markers/target.png'
  };
  String get path => ownGrid ? markPathMapOwn[mark]! : markPathMapOpp[mark]!;

  @override
  Widget build(BuildContext context) => Positioned(
    left: squareSize*base.x,
    top: squareSize*base.y,
    height: squareSize,
    width: squareSize,
    child: Image.asset(path, fit: BoxFit.contain),
  );
}

class BattleshipGrid extends StatelessWidget {
  final bool attackMode;
  final void Function(Coord)? callback;
  final Widget? overlay;
  final void Function(bool isRight)? onSwipe;
  const BattleshipGrid({super.key, this.callback, this.attackMode=false, this.overlay, this.onSwipe});

  static const gridSize = 10;

  @override
  Widget build(BuildContext context) {
    Color getSquareColor(int x, int y, Ship? ship, Shot? shot) {
      if (attackMode) {
        if (ship?.isSunk == true) return Colors.white;
        return [const Color.fromARGB(255, 0, 46, 12), const Color.fromARGB(255, 0, 25, 7)][(x+y) % 2];
      }
      // if (ship != null) return const Color.fromARGB(108, 76, 175, 79); // re-use this for pre-placement
      return [const Color.fromARGB(77, 5, 44, 81), const Color.fromARGB(0, 0, 0, 0)][(x+y) % 2];
    }
    double startPosition = 0;

    return LayoutBuilder(builder: (context, constraints) {
      final squareSize = constraints.maxWidth / gridSize;

      // Because ship and marker assets overlay the grid, we have to use an external gesture detector.
      return Center(child: GestureDetector(
        onHorizontalDragStart: (details) => startPosition = details.localPosition.dx,
        onHorizontalDragEnd: (details) {
          final delta = details.localPosition.dx - startPosition;
          if (onSwipe == null ||delta.abs() < 100) return;
          onSwipe!(delta > 0);
        },
        onTapDown: (TapDownDetails details){
          if (callback == null) return;
          
          final tapped = Coord(details.localPosition.dx ~/ squareSize, details.localPosition.dy ~/ squareSize);
          try {
            tapped.validate();
          } catch (e) {
            return;
          }

          callback!(tapped);
        },
        child: Stack(children: [
        if (!attackMode) Image.asset('assets/images/backdrops/water.jpg', height: squareSize*10, fit: BoxFit.fitHeight),
        GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: gridSize),
          itemCount: gridSize*gridSize,
          itemBuilder: (context, index) {
            int y = index ~/ gridSize;
            int x = index % gridSize;

            return Selector<Grid, GridContent>(
              selector: (_, grid) {
                return GridContent(grid._shipGrid[x][y], grid._shotsGrid[x][y]);
              },
              builder: (context, content, child) => Container(
                  color: getSquareColor(x, y, content.ship, content.shot),
                  alignment: Alignment.center,
                  margin: attackMode ? EdgeInsets.all(1) : null
                ),
            );
        }),
        // Ship images
        if (!attackMode) Selector<Grid, List<Ship>>(
          selector: (_, grid) => grid._ships,
          builder: (context, ships, child) {
            return Stack(children: ships.map<Widget>((s) => PositionedShipImage(squareSize: squareSize, ship: s)).toList());
          }
        ),
        // Markers
        Selector<Grid, List<List<Shot?>>>(
          selector: (_, grid) => grid._shotsGrid,
          builder: (context, shotGrid, child) {
            final List<Widget> markers = [];
            // Iterate over entire grid searching for shots
            for (int x=0; x<10; x++) {
              for (int y=0; y<10; y++) {
                final s = shotGrid[x][y];
                if (s != null) {
                  markers.add(PositionedMarker(Coord(x, y), squareSize, s, !attackMode));
                }
              }
            }
            return Stack(children: markers);
          }
        ),
        // Overlay from state
        if (overlay != null) Center(child: overlay)
      ])));
    }); 
  }
}