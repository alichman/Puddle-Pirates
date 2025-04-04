import 'package:flutter/material.dart';

class CardLibraryScreen extends StatefulWidget {
  const CardLibraryScreen({super.key});

  @override
  State<CardLibraryScreen> createState() => _CardLibraryScreenState();
}

class _CardLibraryScreenState extends State<CardLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  int totalCards = 48;
  String sortOrder = 'Alphabetical';
  int currentPage = 1;
  int totalPages = 4;
  
  // Sample card data
  final List<Map<String, dynamic>> cards = List.generate(
    48,
    (index) => {
      'id': index + 1,
      'name': 'Card ${index + 1}',
      'description': 'Description for card ${index + 1}',
    },
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child:  Scaffold(
      appBar: AppBar(
        title: const Text("Card Library"),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text('Total: $totalCards'),
                const Spacer(),
                const Text('Sort by:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: sortOrder,
                  icon: const Icon(Icons.arrow_downward),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        sortOrder = value;
                      });
                    }
                  },
                  items: ['Alphabetical', 'Rarity', 'Type', 'Cost'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                hintText: 'Enter Text',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 16, // Display 16 cards per page (4x4 grid)
              itemBuilder: (context, index) {
                final cardIndex = (currentPage - 1) * 16 + index;
                if (cardIndex >= cards.length) {
                  return Container();
                }
                
                return InkWell(
                  onTap: () {
                    // Show card detail dialog
                    _showCardDetail(cards[cardIndex]);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        cards[cardIndex]['name'],
                        textAlign: TextAlign.center,
                      ),
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
    ));
  }

  void _showCardDetail(Map<String, dynamic> card) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(card['name']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              const SizedBox(height: 8),
              Text(card['description']),
              const SizedBox(height: 16),
              const Text('Card details would be shown here including stats, abilities, etc.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}