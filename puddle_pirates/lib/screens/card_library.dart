import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for loading assets

class CardLibraryScreen extends StatefulWidget {
  const CardLibraryScreen({super.key});

  @override
  State<CardLibraryScreen> createState() => _CardLibraryScreenState();
}

class _CardLibraryScreenState extends State<CardLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> cards = [];
  int currentPage = 1;
  int cardsPerPage = 4; // Updated for 4 cards per page
  int totalPages = 1;
  String sortOrder = 'Alphabetical';

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    try {
      final String response = await rootBundle.loadString('assets/cards.json');
      final data = json.decode(response);

      setState(() {
        cards = List<Map<String, dynamic>>.from(data['deck']);
        totalPages = (cards.length / cardsPerPage).ceil();
      });
    } catch (e) {
      debugPrint("Error loading cards: $e");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Card Library",
          style: TextStyle(
            fontFamily: "PixelFont",
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: cardsPerPage,
              itemBuilder: (context, index) {
                final cardIndex = (currentPage - 1) * cardsPerPage + index;
                if (cardIndex >= cards.length) {
                  return Container();
                }

                final card = cards[cardIndex];

                return InkWell(
                  onTap: () => _showCardDetail(card),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.asset(
                            card['imagePath'], // Load card image
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image_not_supported, size: 50);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: currentPage > 1
                      ? () {
                          setState(() {
                            currentPage--;
                          });
                        }
                      : null,
                ),
                Text('Page $currentPage/$totalPages'),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: currentPage < totalPages
                      ? () {
                          setState(() {
                            currentPage++;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCardDetail(Map<String, dynamic> card) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blue[100], // Light blue background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          title: Text(
            card['name'],
            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                card['imagePath'], // Display card image
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported, size: 50, color: Colors.blueGrey);
                },
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.blue), // Blue divider
              const SizedBox(height: 8),
              Text(card['description'], style: const TextStyle(color: Colors.black87)),
              const SizedBox(height: 8),
              Text("Type: ${card['type']}", style: const TextStyle(color: Colors.blue)),
              Text("Price: ${card['price']}", style: const TextStyle(color: Colors.blue)),
              Text("Probability: ${card['probability']}", style: const TextStyle(color: Colors.blue)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(backgroundColor: Colors.blue), // Blue button
            ),
          ],
        );
      },
    );
  }

}
