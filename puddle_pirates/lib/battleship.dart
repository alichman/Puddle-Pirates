/*
  File for all logic related to battleship.
  Positions of ships, hits, and misses will be kept in the player's grid.

  Note: (0, 0) is in the top left
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum ShipType {
  destroyer,
  battleship,
  carrier,
  submarine,
  minesweeper,
}

enum Shot { hit, miss }

// Defining our own Point class, since math Point uses num and we want to restrict to ints.
class Coord {
  int x;
  int y;
  Coord(this.x, this.y);

  @override
  String toString() {
    return '($x, $y)';
  }

  void validate() {
    if (x > 9 || x < 0) {
      throw Exception('Coordinate error: x $x is out of range');
    }
    if (y > 9 || y < 0) {
      throw Exception('Coordinate error: y $y is out of range');
    }
  }

  // Allow == comparison between coord objects
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Coord && x == other.x && y == other.y;

  // Hashcode override: maps and such will place this based on the x and y components
  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

const shipLengthMap = {
  ShipType.carrier: 5,
  ShipType.battleship: 4,
  ShipType.submarine: 3,
  ShipType.destroyer: 3,
  ShipType.minesweeper: 2
};

// Temporary display of ships.
const Map<ShipType, Color> shipColorMap = {
  ShipType.carrier: Color.fromARGB(255, 32, 91, 15),
  ShipType.battleship: Color.fromARGB(255, 48, 186, 50),
  ShipType.submarine: Color.fromARGB(255, 28, 111, 29),
  ShipType.destroyer: Color.fromARGB(255, 86, 233, 88),
  ShipType.minesweeper: Color.fromARGB(255, 81, 193, 83),
};

class Ship {
  ShipType type;
  Coord base;
  bool vert;

  Ship(this.type, this.base, this.vert);

  bool isSunk = false;

  List<Coord> getOccupiedSquares() {
    final List<Coord> result = [];
    int x = base.x, y = base.y;
    for (int i = 0; i < shipLengthMap[type]!; i++) {
      result.add(Coord(x, y));
      if (vert) {
        y++;
      } else {
        x++;
      }
    }
    return result;
  }

  @override
  String toString() {
    return '$type at $base (${vert ? 'v' : 'h'})';
  }
}

// Used for selectors based on all grid content.
class GridContent {
  final Ship? ship;
  final Shot? shot;
  final bool underAttack;

  GridContent(this.ship, this.shot, this.underAttack);
}

class Grid extends ChangeNotifier {
  /* Grid containing all of the battleship info.
    Stores two 10x10 grids - one holding all ships,
    and one holding all attacks from the opponent.
    Additionally, ships will be stored in a list, and
    can be used to select their occupied area on the grid.
  */

  // 10x10 null grids
  final List<List<Ship?>> _shipGrid =
      List.generate(10, (_) => List.filled(10, null));
  final List<Ship> _ships = [];
  final List<List<Shot?>> _shotsGrid =
      List.generate(10, (_) => List.filled(10, null));
  List<Coord> underAttack = [];

  List<Ship> get ships => _ships;

  // Abstracted table access
  Ship? getShipFromSquare(Coord square) {
    square.validate();
    return _shipGrid[square.x][square.y];
  }

  Shot? getShotFromSquare(Coord square) {
    square.validate();
    return _shotsGrid[square.x][square.y];
  }

  // Checks line for any ships and hits, as specified by bools.
  // Checks only ships by default.
  bool isLineEmpty(Coord base, int len, bool vert,
      {bool checkShips = true, bool checkHits = false}) {
    int x = base.x, y = base.y;
    for (int i = 0; i < len; i++) {
      if (checkShips && getShipFromSquare(Coord(x, y)) != null) return false;
      if (checkHits && getShotFromSquare(Coord(x, y)) != null) return false;
      if (vert) {
        y++;
      } else {
        x++;
      }
    }
    return true;
  }

  void addShip(ShipType type, Coord base, bool vert) {
    // Validate position
    if (!isLineEmpty(base, shipLengthMap[type]!, vert, checkHits: true))
      throw Exception('Grid Error: Line not empty');

    // Add ship to grid and ships array
    final ship = Ship(type, base, vert);
    final shipLen = shipLengthMap[type]!;

    int x = base.x, y = base.y;
    for (int i = 0; i < shipLen; i++) {
      _shipGrid[x][y] = ship;
      if (vert) {
        y++;
      } else {
        x++;
      }
    }
    _ships.add(ship);
    notifyListeners();
  }

  void removeShip(Ship? ship) {
    if (ship == null) {
      return;
    }
    for (Coord s in ship.getOccupiedSquares()) {
      _shipGrid[s.x][s.y] = null;
    }
    _ships.remove(ship);
    notifyListeners();
  }

  // Checks if a ship is sunk and sets Ship.isSunk.
  // Returns result for local logic.
  bool checkShipSink(Ship ship) {
    final squares = ship.getOccupiedSquares();
    for (Coord s in squares) {
      if (getShotFromSquare(s) == null) return false;
    }

    ship.isSunk = true;
    return true;
  }

  bool checkLoss() {
    for (Ship s in _ships) {
      if (!s.isSunk) return false;
    }
    return true;
  }

  void attack(List<Coord> squares) {
    for (Coord s in squares) {
      s.validate();
      // Don't allow attacks on previous attacked squares.
      if (getShotFromSquare(s) != null)
        throw Exception("Grid Error: Can't attack non-empty square");

      final hitShip = getShipFromSquare(s);
      if (hitShip == null) {
        _shotsGrid[s.x][s.y] = Shot.miss;
      } else {
        _shotsGrid[s.x][s.y] = Shot.hit;
        checkShipSink(hitShip);
      }
    }
    notifyListeners();
  }

  // Sets hit values without additional logic. Not to be used for attacking.
  void setHits(List<Coord> squares, Shot? value) {
    for (Coord s in squares) {
      s.validate();
      _shotsGrid[s.x][s.y] = value;
    }
    notifyListeners();
  }

  // Validates each square, and removes invalid ones.
  // Attack executed by executeAttack() on the current player at that time.
  void setAttack(List<Coord> squares, {bool clearCurrentAttacks = true}) {
    if (clearCurrentAttacks) underAttack = [];

    for (Coord s in squares) {
      try {
        s.validate();
        underAttack.add(s);
      } catch (e) {
        print(e);
      } // Expected error if part of an attack is out of range.
    }
    notifyListeners();
  }

  void executeAttack() {
    attack(underAttack);
    // Attack notifies listeners. No need to do it again.
    underAttack = [];
  }
}

class BattleshipGrid extends StatelessWidget {
  final bool attackMode;
  final void Function(Coord square)? callback;
  const BattleshipGrid({super.key, this.callback, this.attackMode = false});

  static const gridSize = 10;

  @override
  Widget build(BuildContext context) {
    Color getSquareColor(int x, int y, Ship? ship, Shot? shot) {
      if (attackMode) {
        if (ship?.isSunk == true) return Colors.white;

        if (shot == Shot.hit) return Colors.red;
        if (shot == Shot.miss) return Colors.lightBlue;

        return [
          const Color.fromARGB(255, 0, 46, 12),
          const Color.fromARGB(255, 0, 25, 7)
        ][(x + y) % 2];
      }

      if (shot == Shot.hit) return Colors.red;
      if (shot == Shot.miss) return Colors.lightBlue;

      if (ship != null)
        return ship.isSunk ? Colors.black : shipColorMap[ship.type]!;
      return [
        const Color.fromARGB(255, 15, 44, 148),
        const Color.fromARGB(255, 1, 44, 80)
      ][(x + y) % 2];
    }

    // Cenetered 10x10 grid. Size is handled externally.
    return Center(
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize),
            itemCount: gridSize * gridSize,
            itemBuilder: (context, index) {
              int y = index ~/ gridSize;
              int x = index % gridSize;

              // Each cell is its own gesture detector, and updates individually
              // based on the corresponding grid cell's value.
              return Selector<Grid, GridContent>(selector: (_, grid) {
                return GridContent(grid._shipGrid[x][y], grid._shotsGrid[x][y],
                    grid.underAttack.contains(Coord(x, y)));
              }, builder: (context, content, child) {
                final ship = content.ship;
                final shot = content.shot;
                final underAttack = content.underAttack;

                return GestureDetector(
                    onTap: () {
                      if (callback != null) {
                        callback!(Coord(x, y));
                      }
                    },
                    child: Container(
                      color: getSquareColor(x, y, ship, shot),
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(1),
                      child: Text(
                        underAttack ? 'attacked' : '',
                        style: TextStyle(backgroundColor: Colors.white),
                      ),
                    ));
              });
            }));
  }
}
