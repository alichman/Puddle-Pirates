/*
  File for all logic related to battleship.
  Positions of ships, hits, and misses will be kept in the player's grid.

  Note: (0, 0) is in the top left
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puddle_pirates/states.dart';


enum ShipType {
  destroyer,
  battleship,
  carrier,
  submarine,
  minesweeper,
}

enum Shot {
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

  void validate () {
    if (x > 9 ||  x < 0) {
      throw Exception('Coordinate error: x $x is out of range');
    }
    if (y > 9 || y < 0) {
      throw Exception('Coordinate error: y $y is out of range');
    }
  }
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
  ShipType.carrier: Color.fromARGB(255, 0, 42, 1),
  ShipType.battleship: Color.fromARGB(255, 11, 87, 12),
  ShipType.submarine: Color.fromARGB(255, 28, 111, 29),
  ShipType.destroyer: Color.fromARGB(255, 54, 144, 55),
  ShipType.minesweeper: Color.fromARGB(255, 81, 193, 83),
};

class Ship {
  ShipType type;
  Coord base;
  bool vert;

  Ship(this.type, this.base, this.vert);

  List<Coord> getOccupiedSquares() {
    final List<Coord> result = [];
    int x = base.x, y = base.y;
    for (int i=0; i < shipLengthMap[type]!; i++) {
      result.add(Coord(x, y));
      if(vert) {y ++;} else {x++;}
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
  final List<List<Shot?>> _hitsGrid = List.generate(10, (_) => List.filled(10, null));

  // Abstracted table access
  Ship? getShipFromSquare (Coord square) {
    square.validate();
    return _shipGrid[square.x][square.y];
  }

  Shot? getShotFromSquare (Coord square) {
    square.validate();
    return _hitsGrid[square.x][square.y];
  }

  // Checks line for any ships and hits, as specified by bools.
  // Checks only ships by default.
  bool isLineEmpty(Coord base, int len, bool vert, {bool checkShips=true, bool checkHits=false}) {
    int x = base.x, y = base.y;
    for (int i=0; i < len; i++) {
      if(checkShips && getShipFromSquare(Coord(x, y)) != null) return false;
      if(checkHits && getShotFromSquare(Coord(x, y)) != null) return false;
      if(vert) {y ++;} else {x++;}
    }
    return true;
  }

  void addShip (ShipType type, Coord base, bool vert) {
    // Validate position
    if (!isLineEmpty(base, shipLengthMap[type]!, vert, checkHits: true)) throw Exception('Grid Error: Line not empty');
    
    // Add ship to grid and ships array
    final ship = Ship(type, base, vert);
    final shipLen = shipLengthMap[type]!;

    int x = base.x, y = base.y;
    for (int i=0; i < shipLen; i++) {
      _shipGrid[x][y] = ship;
      if(vert) {y ++;} else {x++;}
    }
    _ships.add(ship);
    notifyListeners();
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

  void attack (Coord square) {
    square.validate();

    // Don't allow attacks on previous attacked squares.
    if (getShotFromSquare(square) != null) throw Exception("Grid Error: Can't attack non-empty square");
    
    _hitsGrid[square.x][square.y] = getShipFromSquare(square) == null ? Shot.miss : Shot.hit;
    notifyListeners();
  }

  // Sets hit values without additional logic. Not to be used for attacking.
  void setHits (List<Coord> squares, Shot? value) {
    for (Coord s in squares) {
      s.validate();
      _hitsGrid[s.x][s.y] = value;
    }
    notifyListeners();
  }
}

// Display section
// Battleship graphics will be handled here
// Basically all temporary and for refference only.

// Temporary full page.
class BattleshipPage extends StatefulWidget {
  const BattleshipPage({super.key});
  
  @override
  State<BattleshipPage> createState() => _BattleshipPageState();
}

class _BattleshipPageState extends State<BattleshipPage> {
  // Temporary test player
  Player player = Player('test 1');

  /* Horrific mode handling. Worst code ever written. 
  I'm glad this will be deleted as soon as UI is done.
  This only exists to test different functions.
      0 - add a horizontal submarine
      1 - add a vertical carrier
      2 - delete ship
      4 - Fire
      5 - Heal ship fully
  */
  int mode = 0;
  List<String> modeText = ['Add H sub',
                          'Add V Carrier',
                          'Delete',
                          'Fire',
                          'Heal'];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(child: ChangeNotifierProvider.value(
        value: player.grid,
        child: Center(child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.95, // Take up 80% of the screen width.
          child: BattleshipGrid()
        ),
      ))),
      TextButton(onPressed: () => setState(() => mode = (mode+1) % 5), child: Text('Mode: $mode (${modeText[mode]})'))
      ]);
  }
}

class BattleshipGrid extends StatelessWidget {
  final void Function(Coord square)? callback;
  
  const BattleshipGrid({super.key, this.callback});

  static const gridSize = 10;

  @override
  Widget build(BuildContext context) {
    
    Color getSquareColor(int x, int y, Ship? ship) {
      if (ship == null) {
        return [const Color.fromARGB(255, 255, 187, 182),
         const Color.fromARGB(255, 189, 225, 255)][(x+y) % 2];
      }
      return shipColorMap[ship.type]!;
    }

    // Cenetered 10x10 grid. Size is handled externally.
    return Center(child: GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: gridSize),
      itemCount: gridSize*gridSize,
      itemBuilder: (context, index) {
        int y = index ~/ gridSize;
        int x = index % gridSize;

        // Each cell is its own gesture detector, and updates individually
        // based on the corresponding grid cell's value. 
        return Selector<Grid, GridContent?>(
          selector: (_, grid) => GridContent(grid._shipGrid[x][y], grid._hitsGrid[x][y]) ,
          builder: (context, content, child) {
            final ship = content?.ship;
            final shot = content?.shot;
            return GestureDetector(
              onTap: (){
                print('$x $y');
                if (callback != null) {
                  callback!(Coord(x, y));
                }
              },
              child: Container(
                color: getSquareColor(x, y, ship),
                alignment: Alignment.center,
                margin: EdgeInsets.all(1),
                child: Text('${{Shot.hit: 'hit', Shot.miss: 'miss', null: ''}[shot]}', style: TextStyle(backgroundColor: Colors.white),),
              ));
          });
      }));
  }
}