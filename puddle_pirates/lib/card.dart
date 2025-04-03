import 'package:flutter/material.dart';

enum CardType {
  infrastructure,
  booster,
  intercept,
  deployment
}

const stringToCardTypeMap = {
  "Intercept": CardType.intercept,
  "Booster": CardType.booster,
  "Deployment": CardType.deployment,
  "Infrastructure": CardType.infrastructure,
};

class GameCard {
  final String id;
  final String name;
  final int price;
  final String description;
  final double probability;
  final String callbackString;
  CardType type;

  GameCard({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    required this.description,
    required this.probability,
    required this.callbackString,
  });

  void Function(BuildContext)? effect;

  /// Converts JSON data to a GameCard object.
  factory GameCard.fromJson(Map<String, dynamic> json) {
    return GameCard(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      type: stringToCardTypeMap[json['type']]!, // Unsafe intentionally. Game should crash if a JSON contains an impossible card.
      description: json['description'],
      probability: (json['probability'] as num).toDouble(),
      callbackString: json['callback'],
    );
  }
}

/// Visual GameCard Widget, can be clicked/tapped to execute its callback.
class CardWidget extends StatelessWidget {
  final GameCard card;
  final VoidCallback? callback;
  final bool playable;
  /// skipEffect differs from playable:
  // Playable is intended to change the UI to show whether or not
  // a card can be played. It skips over everything on tap.
  // skipEffect shows the card as if it's playable,
  // but only calls the callback, not the effect.
  final bool skipEffect;

  /// Requires the GameCard object, its callback function, and your function to remove the card when it is played.
  const CardWidget({
      super.key,
      required this.card,
      this.callback,
      this.playable = true,
      this.skipEffect = false
    });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!playable) return;
        if(!skipEffect) card.effect!(context);
        if (callback != null) callback!();
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: playable ? Colors.white : Colors.grey,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(children: [Text(card.name), Text('\$${card.price}')])
      ),
    );
  }
}
