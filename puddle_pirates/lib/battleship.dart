/*
  File for all logic related to battleship.
  Positions of ships, hits, and misses will be kept in the player's grid.

  Note: (0, 0) is in the top left
*/

import 'package:flutter/material.dart';

enum ShipType {
  destroyer,
  battleship,
  carrier,
  submarine,
  minesweeper,
}

enum ShotResult {
  hit,
  miss
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
}

const shipLengthMap = {
  ShipType.carrier: 5,
  ShipType.battleship: 4,
  ShipType.submarine: 3,
  ShipType.destroyer: 3,
  ShipType.minesweeper: 2
};

class Ship {
  ShipType type;
  Coord base;
  bool vert;

  Ship(this.type, this.base, this.vert);

  @override
  String toString() {
    return '$type at $base (${vert ? 'v' : 'h'})';
  }
}

class Grid {
  // 10x10 null grid
  final List<List<Ship?>> _shipGrid = List.generate(10, (_) => List.filled(10, null));
  final List<Ship> _ships = [];
  
  // Returns ship
  Ship? getShipFromSquare (Coord square) {
    if (square.x > 10 || square.x < 0 ) throw Exception('Grid Error: x=${square.x} is out of bounds.');
    if (square.y > 10 || square.y < 0 ) throw Exception('Grid Error: y=${square.y} is out of bounds.');
    return _shipGrid[square.x][square.y];
  }

  // Checks line for any ships.
  bool isLineEmpty(Coord base, int len, bool vert) {
    if (vert) {
      for (int y = base.y; y < base.y + len - 1; y++) {
        if(getShipFromSquare(Coord(base.x, y)) != null) return false;
      }
    } else {
      for (int x = base.x; x < base.x + len - 1; x++) {
        if(getShipFromSquare(Coord(x, base.y)) != null) return false;
      }
    }

    return true;
  }

  void addShip (ShipType type, Coord base, bool vert) {
    print('Adding $type at $base');
    // Validate position
    if (!isLineEmpty(base, shipLengthMap[type]!, vert)) throw Exception('Grid Error: Line not empty');
    
    // Add ship to grid and ships array
    final ship = Ship(type, base, vert);
    final shipLen = shipLengthMap[type]!;

    int x = base.x, y = base.y;
    for (int i=0; i < shipLen - 1; i++) {
      _shipGrid[x][y] = ship;
      if(vert) {y ++;} else {x++;}
    }
    _ships.add(ship);
    print('success $ship');
  }
}

// Global grid for any ongoing game.
// TODO: move to state once that's well defined.
Grid currentGameGrid = Grid();

// Display section
// Battleship graphics will be handled here

// Temporary full page.
class BattleshipPage extends StatefulWidget {
  const BattleshipPage({super.key});
  
  @override
  State<BattleshipPage> createState() => _BattleshipPageState();
}

class _BattleshipPageState extends State<BattleshipPage> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95, // Take up 80% of the screen width.
        child: BattleshipGrid()
      ),
    );
  }
}

class BattleshipGrid extends StatelessWidget {
  const BattleshipGrid({super.key});

  static const gridSize = 10;

  @override
  Widget build(BuildContext context) {
    
    Color getSquareColor(Coord square) {
      if (currentGameGrid.getShipFromSquare(square) == null) {
        return [const Color.fromARGB(255, 255, 187, 182), const Color.fromARGB(255, 189, 225, 255)][(square.x + square.y) % 2];
      }
      return Colors.green;
    }

    return Center(child: GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: gridSize),
      itemCount: gridSize*gridSize,
      itemBuilder: (context, index) {
        int y = index ~/ gridSize;
        int x = index % gridSize;

        return GestureDetector(
          onTap: () => currentGameGrid.addShip(ShipType.submarine, Coord(x, y), false),
          child: Container(
            color: getSquareColor(Coord(x, y)),
            alignment: Alignment.center,
            child: Text('$x, $y'),
            margin: EdgeInsets.all(1),
          )
        );
      },
      ));
  }
}