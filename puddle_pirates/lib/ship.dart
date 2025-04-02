import 'package:flutter/material.dart';
import 'package:puddle_pirates/battleship.dart';

enum ShipType {
  patrol,
  destroyer,
  submarine,
  cruiser,
  battleship,
}
extension Name on ShipType {
  String get name {
    switch (this) {
      case ShipType.patrol: return 'patrol';
      case ShipType.destroyer: return 'destroyer';
      case ShipType.submarine: return 'sub';
      case ShipType.cruiser: return 'cruiser';
      case ShipType.battleship: return 'battleship';
    }
  }
}

const shipLengthMap = {
  ShipType.battleship: 5,
  ShipType.submarine: 4,
  ShipType.cruiser: 4,
  ShipType.destroyer: 3,
  ShipType.patrol: 2
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
    for (int i=0; i < shipLengthMap[type]!; i++) {
      result.add(Coord(x, y));
      if(vert) {y ++;} else {x++;}
    }
    return result;
  }

  String get assetPath => 'assets/images/ships/${type.name}.png';

  @override
  String toString() {
    return '$type at $base (${vert ? 'v' : 'h'})';
  }
}


class PositionedShipImage extends StatelessWidget{
  final double squareSize;
  final Ship ship;

  const PositionedShipImage({super.key, required this.squareSize, required this.ship});

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(ship.assetPath, fit: BoxFit.contain);

    final length = squareSize * shipLengthMap[ship.type]!;
    final width = squareSize * 0.9;

    return Positioned(
      left: squareSize * ship.base.x + 2, // Slight manual offset for centering
      top: squareSize * ship.base.y,
      height: ship.vert ? length : width,
      width: ship.vert ? width: length,
      child: ship.vert ? RotatedBox(quarterTurns: 1, child: img) : img
    );
  }
}