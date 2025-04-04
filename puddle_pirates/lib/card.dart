import 'package:flutter/material.dart';

enum CardType {
  infrastructure,
  booster,
  intercept,
  deployment
}
extension Name on CardType {
  String get name {
    switch (this) {
      case CardType.intercept: return 'Intercept';
      case CardType.booster: return 'Booster';
      case CardType.deployment: return 'Deployment';
      case CardType.infrastructure: return 'Infrastructure';
    }
  }
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
  final String imagePath;
  CardType type;

  GameCard({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    required this.description,
    required this.probability,
    required this.callbackString,
    required this.imagePath,
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
      imagePath: json['imagePath'],
    );
  }
}

const detailLevelHeightMap = {
  1: 150.0,
  2: 250.0,
  3: 250.0,
};

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
  // Detail levels:
  // 1 - Collapsed, Only neccessary info.
  // 2 - Standard, includes description.
  // 3 - All displayable information.
  final int detailLevel;

  /// Requires the GameCard object, its callback function, and your function to remove the card when it is played.
  const CardWidget({
      super.key,
      required this.card,
      this.callback,
      this.playable = true,
      this.skipEffect = false,
      this.detailLevel = 1,
    });

  @override
  Widget build(BuildContext context) {
    const blackTextStyle = TextStyle(color: Color.fromARGB(255, 26, 13, 0));

    return GestureDetector(
      onTap: () {
        if (!playable) return;
        if (!skipEffect) card.effect!(context);
        if (callback != null) callback!();
      },
      child: Container(
        height: detailLevelHeightMap[detailLevel],
        width: 300,
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: playable ? const Color.fromARGB(255, 255, 219, 190) : Colors.grey,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            // Display card image
            if (card.imagePath.isNotEmpty)
              Image.asset(
                card.imagePath,
                height: 100, // Adjust based on layout
                fit: BoxFit.cover,
              ),
            SizedBox(height: 8),
            Text(card.name, style: blackTextStyle),
            Text('\$${card.price}', style: blackTextStyle),
            Text(card.type.name, style: blackTextStyle),
            Expanded(child: SizedBox.shrink()),
            if (detailLevel > 1)
              Text(
                card.description,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),
              ),
          ],
        ),
      ),
    );
  }
}
