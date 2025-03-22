import 'package:flutter/material.dart';

class GameCard {
  final String id;
  final String name;
  final int price;
  final String type;
  final String description;
  final double probability;
  final String callback;

  GameCard({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    required this.description,
    required this.probability,
    required this.callback,
  });

  /// Converts JSON data to a GameCard object.
  factory GameCard.fromJson(Map<String, dynamic> json) {
    return GameCard(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      type: json['type'],
      description: json['description'],
      probability: (json['probability'] as num).toDouble(),
      callback: json['callback'],
    );
  }
}

/// Visual GameCard Widget, can be clicked/tapped to execute its callback.
class CardWidget extends StatelessWidget {
  final GameCard card;
  final VoidCallback callback;
  final VoidCallback remove;

  /// Requires the GameCard object, its callback function, and your function to remove the card when it is played.
  const CardWidget(
      {super.key,
      required this.card,
      required this.callback,
      required this.remove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        callback(),
        remove(),
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(card.name),
      ),
    );
  }
}
