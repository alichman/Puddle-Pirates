import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class DeckPage extends StatelessWidget {
  const DeckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Deck Component',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const DeckHomePage(),
    );
  }
}

class DeckHomePage extends StatefulWidget {
  const DeckHomePage({super.key});

  @override
  _DeckHomePageState createState() => _DeckHomePageState();
}

class _DeckHomePageState extends State<DeckHomePage> {
  List<GameCard> deck = [];
  List<GameCard> drawnCards = [];
  String logMessage = '';
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    initializeDeck();
  }

  /// Loads the deck from a JSON file and stores card probabilities.
  Future<void> initializeDeck() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/cards.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> deckJson = jsonData['deck'];

      setState(() {
        deck = deckJson.map((cardJson) => GameCard.fromJson(cardJson)).toList();
        logMessage = 'Deck initialized with ${deck.length} unique cards.';
      });
    } catch (e) {
      setState(() {
        logMessage = 'Error initializing deck: $e';
      });
    }
  }

  /// Draws a card based on its assigned probability.
  GameCard drawCard() {
    if (deck.isEmpty) {
      setState(() {
        logMessage = 'Error: No cards available in deck.';
      });
      throw Exception('No cards available in deck.');
    }

    double totalProbability = deck.fold(
      0,
      (sum, card) => sum + card.probability,
    );
    double drawPoint = random.nextDouble() * totalProbability;
    double cumulative = 0;

    for (var card in deck) {
      cumulative += card.probability;
      if (drawPoint <= cumulative) {
        setState(() {
          drawnCards.insert(0, card);
          logMessage = 'You drew: ${card.name}';
        });
        return card;
      }
    }
    throw Exception('Failed to draw a card due to unexpected error.');
  }

  /// Gives a specific card to a player. May need slight revision when player hands are implemented.
  GameCard giveCard(String cardName) {
    for (var card in deck) {
      if (cardName == card.name) {
        drawnCards.insert(0, card);
        logMessage = '${card.name} added to your hand.';
        return card;
      }
    }
    throw Exception('Specified card not found in deck.');
  }

  /// Removes the played card and invokes its callback function. May need slight revision when player hands are implemented.
  void playCard(String callback) {
    if (drawnCards.isEmpty) {
      setState(() {
        logMessage = 'Error: No cards drawn yet.';
      });
      return;
    }

    GameCard card = drawnCards.removeAt(0);
    setState(() {
      logMessage = 'Played: ${card.name}';
    });

    switch (card.callback) {
      case 'tacticalRepositioning':
        tacticalRepositioning();
        break;
      case 'volleyFire':
        volleyFire();
        break;
      case 'repairCrew':
        repairCrew();
        break;
      case 'intelligence':
        intelligence();
        break;
      default:
        setState(() {
          logMessage = 'Error: Unknown card callback.';
        });
    }
  }

  /// Returns the top [x] drawn cards. Legacy from original implementation with limited cards but may still see use
  List<GameCard> seeTopXCards(int x) {
    return drawnCards.take(x).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Deck'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(onPressed: drawCard, child: const Text("Draw Card")),
            const SizedBox(height: 20),
            Text(
              logMessage,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: drawnCards.length,
                itemBuilder: (context, index) {
                  final card = drawnCards[index];
                  return ListTile(
                    title: Text(card.name),
                    subtitle: Text(
                      "Price: ${card.price} | ${card.description}",
                    ),
                    onTap: () => playCard(card.callback),
                    trailing: card.isInfrastructure
                        ? const Icon(Icons.build, color: Colors.blueAccent)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Callback Functions (Placeholders)
  void tacticalRepositioning() {
    print("Tactical Repositioning Callback");
  }

  void volleyFire() {
    print("Volley Fire Callback");
  }

  void repairCrew() {
    print("Repair Crew Callback");
  }

  void intelligence() {
    print("Intelligence Callback");
  }
}

/// Represents a single game card.
class GameCard {
  final String id;
  final String name;
  final int price;
  final String description;
  final double probability;
  final String callback;
  final bool isInfrastructure;

  GameCard({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.probability,
    required this.callback,
    this.isInfrastructure = false,
  });

  /// Creates a GameCard from JSON data.
  factory GameCard.fromJson(Map<String, dynamic> json) {
    return GameCard(
      id: json['id'] as String,
      name: json['name'] as String,
      price: json['price'] as int,
      description: json['description'] as String,
      probability: (json['probability'] as num).toDouble(),
      callback: json['callback'] as String,
      isInfrastructure: json['isInfrastructure'] as bool? ?? false,
    );
  }
}
